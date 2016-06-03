import Argo
import Curry
import Firebase

struct Product: Modelable {
  let id: String?
  let name: String
  let barcode: String
  let quantity: Int
  let price: Cents
  let currency: Currency
  var userId: String

  func decrement(by decrementDelta: Int = 1) -> Product {
    return Product(
      id: id,
      name: name,
      barcode: barcode,
      quantity: quantity - decrementDelta,
      price: price,
      currency: currency,
      userId: userId
    )
  }
}

extension Product: Decodable {
  static func decode(json: JSON) -> Decoded<Product> {
    return curry(Product.init)
      <^> json <|? "id"
      <*> json <| "name"
      <*> json <| "barcode"
      <*> json <| "quantity"
      <*> json <| "price"
      <*> json <| "currency"
      <*> json <| "user_id"
  }
}

extension Product: Encodable {
  func encode() -> [String: AnyObject] {
    return [
      "name": name,
      "barcode": barcode,
      "quantity": quantity,
      "price": price,
      "currency": currency.rawValue,
      "user_id": userId
    ]
  }
}
