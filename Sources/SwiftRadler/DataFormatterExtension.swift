import Foundation

// Unfortunately the Foundation library does not support iso8601 times
// that include fractional seconds (02:55.000).
public extension DateFormatter {
   
   static let iso8601Full: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
      formatter.calendar = Calendar(identifier: .iso8601)
//      formatter.timeZone = TimeZone(secondsFromGMT: 0)
      formatter.locale = Locale(identifier: "en_US_POSIX")
      return formatter
   }()

   static let iso8601Minimal: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
      formatter.calendar = Calendar(identifier: .iso8601)
//      formatter.timeZone = TimeZone(secondsFromGMT: 0)
      formatter.locale = Locale(identifier: "en_US_POSIX")
      return formatter
   }()

   static let iso8601FormatterLocal: ISO8601DateFormatter = {
      let formatter = ISO8601DateFormatter()
      formatter.formatOptions = [.withFullDate,
                                 .withTime,
                                 .withDashSeparatorInDate,
                                 .withColonSeparatorInTime]
      formatter.timeZone = TimeZone.current
      return formatter
   }()
   
   static let iso8601FormatterUTC: ISO8601DateFormatter = {
      let formatter = ISO8601DateFormatter()
      formatter.formatOptions = [.withFullDate,
                                 .withTime,
                                 .withDashSeparatorInDate,
                                 .withColonSeparatorInTime]
      formatter.timeZone = TimeZone(abbreviation: "UTC")
      return formatter
   }()
}
