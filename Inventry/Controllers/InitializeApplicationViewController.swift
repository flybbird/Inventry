import UIKit
import Async
import Firebase
import RxSwift
import Argo
import Runes

class InitializeApplicationViewController: UIViewController {
  let disposeBag = DisposeBag()

  override func viewDidLoad() {
    if store.isSignedIn {
      store.firUser
        .timeout(3, scheduler: MainScheduler.instance)
        .flatMap { user in
          // Verify user exists to prevent decoding errors breaking stuff
          return store.dispatch(CreateUser(firUser: user, connectAccount: StripeConnectAccount.null()))
        }.flatMap { userID in
          return UserQuery(id: userID).build()
        }.take(1)
        .map { $0.accountSetupComplete }
        .subscribe(
          onNext: { accountSetupComplete in
            accountSetupComplete ? self.startMain() : self.startOnboarding()
          },
          onError: { error in
            print(error)
            _ = try? FIRAuth.auth()?.signOut()
            self.startOnboarding()
          }
        ).addDisposableTo(disposeBag)
    } else {
      startOnboarding()
    }
  }

  fileprivate func startOnboarding() {
    Async.main { self.performSegue(withIdentifier: "onboardingSegue", sender: self) }
  }

  fileprivate func startMain() {
    Async.main { self.performSegue(withIdentifier: "mainSegue", sender: self) }
  }
}
