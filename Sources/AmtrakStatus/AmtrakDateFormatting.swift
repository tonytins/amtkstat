import Foundation

struct AmtrakDateFormatting {
    let isoFormatter = ISO8601DateFormatter()
    
    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    func parsedDate(from isoString: String?) -> Date? {
        guard let isoString, !isoString.isEmpty, let date = isoFormatter.date(
            from: isoString) else {
            return nil
        }
        
        return isoFormatter.date(from: isoString)
    }
    
    func time(from isoString: String?, timeZone: TimeZone? = nil) -> String? {
        guard let isoString, !isoString.isEmpty, let date = isoFormatter.date(
            from: isoString) else {
            return nil
            }
        timeFormatter.timeZone = timeZone
        return timeFormatter.string(from: date)
    }
    
    func date(from isoString: String?) -> String? {
        guard let isoString, !isoString.isEmpty, let date = isoFormatter.date(
            from: isoString) else {
            return nil
        }
        
        return dateFormatter.string(from: date)
    }
}
