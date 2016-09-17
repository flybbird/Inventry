import Firebase
import RxSwift

/// This class is used to hydrate the Delta store with data from Firebase
/// and update it if necessary so we're using it rather than Firebase's API
/// across the app. It should live as a singleton on the AppDelegate, so we
/// don't need to worry about deallocating listeners.
class FirebaseSyncController {
  let disposeBag = DisposeBag()

  func sync() {
    observeAuthState()
    observeProducts()
    observeOrders()
  }

  private func observeAuthState() {
    FIRAuth.auth()?.addAuthStateDidChangeListener { _, firUser in
      store.dispatch(UpdateAuth(firUser: firUser))
    }

    store.firUser
      .flatMapLatest { Database.observeObject(ref: User.getChildRef($0.uid)) }
      .retry()
      .subscribeNext { (user: User) in
        store.dispatch(UpdateAuth(user: user))
      }.addDisposableTo(disposeBag)
  }

  private func observeProducts() {
    store.user.flatMapLatest { user -> Observable<[Product]> in
      return Database.find(ids: user.products)
    }.subscribeNext { products in
      let sortedByName = products.sort { lhs, rhs in lhs.name < rhs.name }
      store.dispatch(SetAllProducts(products: sortedByName))
    }.addDisposableTo(disposeBag)
  }

  private func observeOrders() {
    store.user.flatMapLatest { user -> Observable<[Order]> in
      return Database.find(ids: user.orders)
    }.subscribeNext { orders in
      let sortedByCreated = self.sortByCreated(orders)
      store.dispatch(SetAllOrders(orders: sortedByCreated))
    }.addDisposableTo(disposeBag)
  }

  private func sortByCreated<T: Timestampable>(models: [T]) -> [T] {
    return models.sort { lhs, rhs in
      guard let lCreated = lhs.timestamps?.createdAt, rCreated = rhs.timestamps?.createdAt
        else { return true }
      return lCreated.compare(rCreated) == .OrderedDescending
    }
  }
}
