import Foundation

struct AmtrakDateFormatting {
    static let isoFormatter = ISO8601DateFormatter()
    
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    static func time(from isoString: String?) -> String? {
        guard let isoString, !isoString.isEmpty, let date = isoFormatter.date(
            from: isoString) else {
            return nil
            }
        
        return timeFormatter.string(from: date)
    }
    
    static func date(from isoString: String?) -> String? {
        guard let isoString, !isoString.isEmpty, let date = isoFormatter.date(
            from: isoString) else {
            return nil
        }
        
        return dateFormatter.string(from: date)
    }
}
