import Argo

typealias Cents = Int

enum Currency: String {
  case USD = "usd"
}

extension Currency: Decodable {
  static func decode(j: JSON) -> Decoded<Currency> {
    switch j {
    case let .String(s): return .fromOptional(Currency(rawValue: s))
    default: return .typeMismatch("Currency", actual: j)
    }
  }
}
