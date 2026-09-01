import Foundation

extension Int {
  func pluralized(singular: String, plural: String) -> String {
    self == 1 ? singular : plural
  }
}
