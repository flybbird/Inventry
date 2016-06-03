import UIKit
import RxSwift

class OrdersTableViewController: UITableViewController {
  var orders: [Order] = [] { didSet { tableView.reloadData() } }
  let disposeBag = DisposeBag()

  override func viewDidLoad() {
    AuthenticationController().present(onViewController: self)

    store.allOrders.subscribeNext { [weak self] in self?.orders = $0 }.addDisposableTo(disposeBag)

    // Empty back button for next screen
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
  }

  @IBAction func unwindToOrders(sender: UIStoryboardSegue) {
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    guard let identifier = segue.identifier else { return }

    switch identifier {
    case "showOrder":
      guard let vc = segue.destinationViewController as? OrderReviewViewController,
            let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPathForCell(cell)
        else { return }

      // Since we're reusing the review order VC, we want to nil the "Place Order" button and
      // change "Review" title. Note: We're basically abusing this VC and store state
      let order = orders[indexPath.row]
      store.dispatch(SetOrder(order: order))
      vc.navigationItem.rightBarButtonItem = .None
      if let createdAt = order.timestamps?.createdAt {
        vc.navigationItem.title = DateFormatter(createdAt).formatted
      } else {
        vc.navigationItem.title = .None
      }
    default: break
    }
  }
}

// MARK: UITableViewDataSource
extension OrdersTableViewController {
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return orders.count
  }
}

// MARK: UITableViewDelgate
extension OrdersTableViewController {
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("orderCell", forIndexPath: indexPath)
    let order = orders[indexPath.row]
    cell.textLabel?.text = order.customer?.name
    if let price = PriceFormatter(order)?.formatted {
      cell.detailTextLabel?.text = price
    } else {
      cell.detailTextLabel?.text = .None
    }
    return cell
  }
}
