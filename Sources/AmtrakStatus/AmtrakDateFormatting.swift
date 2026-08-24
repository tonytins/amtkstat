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
    
    func time(from isoString: String?, timeZone: TimeZone?, relativeTo otherZone: TimeZone? = nil) -> String? {
        guard let isoString, !isoString.isEmpty, let date = isoFormatter.date(
            from: isoString) else {
            return nil
            }
        
        timeFormatter.timeZone = timeZone
        
        let formatted = timeFormatter.string(from: date)
        
        guard
            let timeZone,
            let otherZone,
            timeZone.identifier != otherZone.identifier,
            let abbreviation = timeZone.abbreviation(for: date)
        else {
            return formatted
        }
        
        return "\(formatted) \(abbreviation)"
    }
    
    func localTime(timeZone: TimeZone?) -> String {
        let now = Date()
        timeFormatter.timeZone = timeZone
        return timeFormatter.string(from: now)
    }
    
    func updateTime(timeZone: TimeZone?) {
        let now = Date()
        timeFormatter.timeZone = timeZone
    }
    
    func date(from isoString: String?) -> String? {
        guard let isoString, !isoString.isEmpty, let date = isoFormatter.date(
            from: isoString) else {
            return nil
        }
        
        return dateFormatter.string(from: date)
    }
}
