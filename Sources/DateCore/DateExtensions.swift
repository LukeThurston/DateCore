import Foundation

public extension Date {
    // MARK: - Common String Formats
    /// The suffix for the date: st, nd, rd, th
    var daySuffix: String {
        guard let dayComponent = Calendar.current.dateComponents([.day], from: self).day else { return "" }
        switch dayComponent {
        case 1, 21, 31: return "st"
        case 2, 22: return "nd"
        case 3, 23: return "rd"
        default: return "th"
        }
    }
    
    /// The day is a relative way: Today, Tomorrow, else weekday: Monday, Tuesday, Etc
    var relativeDayString: String {
        if self.isToday { return "Today" }
        else if self.isTomorrow { return "Tomorrow" }
        return self.formatted("EEEE")
    }
    
    /// The day is a relative way: Today, Tomorrow, or if within the current week the weekday: Monday, Tuesday, Else Weekday and date e.g. Monday 6th
    var relativeDateString: String {
        if isWithinWeekIgnoringTimeComponents {
            if self.isToday { return "Today" }
            else if self.isTomorrow { return "Tomorrow" }
            else if isBefore(endOfWeek, ignoringTimeComponents: true) { return self.formatted("EEEE") }
            let dayComponent = Calendar.current.component(.day, from: self)
            return "\(self.formatted("EEEE")) \(dayComponent)\(daySuffix)"
        } else {
            return self.formatted("dd/MM/yyyy")
        }
    }
    
    // MARK: - Start and End
    
    /// First date of year
    var startOfYear: Date? {
        let year = Calendar.current.component(.year, from: self)
        return Date(from: "01/01/\(year)", format: "dd/MM/yyyy")
    }
    
    /// Last date of year
    var endOfYear: Date? {
        let year = Calendar.current.component(.year, from: self)
        return Date(from: "31/12/\(year) 23:59:59", format: "dd/MM/yyyy HH:mm:ss")
    }
    
    /// First date of the month
    var startOfMonth: Date {
        return Calendar.current.startOfDay(for: self).withComponents([.year, .month]).startOfDay
    }
    
    /// Last date of the month
    var endOfMonth: Date? {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!.endOfDay
    }
    
    /// First date of week
    var startOfWeek: Date {
        let calendar = Calendar.current
        guard let sunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return Date() }
        return calendar.date(byAdding: .day, value: 1, to: sunday)?.startOfDay ?? Date()
    }
    
    /// Last date of week
    var endOfWeek: Date {
        let calendar = Calendar.current
        guard let sunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return Date() }
        return calendar.date(byAdding: .day, value: 7, to: sunday)?.endOfDay ?? Date()
    }
    
    /// First instance of date
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    /// Last instance of date
    var endOfDay: Date? {
        let comps = Calendar.current.dateComponents([.year, .month, .day], from: self)
        guard let day = comps.day, let month = comps.month, let year = comps.year else { return nil }
        return Date(from: "\(day)/\(month)/\(year) 23:59:59", format: "dd/MM/yyyy HH:mm:ss")
    }
    
    // MARK: - Checks
    
    var isToday: Bool {
        return self.isOnSameDay(asDate: Date())
    }
    
    var isTomorrow: Bool {
        return self.isOnSameDay(asDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date().addingTimeInterval(.dayInSeconds))
    }
    
    var isWithinWeekIgnoringTimeComponents: Bool {
        let nextWeek = Calendar.current.date(byAdding: .weekday, value: 7, to: Date()) ?? Date().addingTimeInterval(.weekInSeconds)
        return self.isBefore(nextWeek, ignoringTimeComponents: true) && self.isAfter(Date(), ignoringTimeComponents: true)
    }
    
    func isBefore(_ date: Date, ignoringTimeComponents: Bool = false) -> Bool {
        if ignoringTimeComponents {
            return self.withComponents([.year, .month, .day]) <= date.withComponents([.year, .month, .day])
        }
        return self <= date
    }
    
    func isAfter(_ date: Date, ignoringTimeComponents: Bool = false) -> Bool {
        if ignoringTimeComponents {
            return self.withComponents([.year, .month, .day]) >= date.withComponents([.year, .month, .day])
        }
        return self >= date
    }
    
    // MARK: - Funcs
    
    /// Returns a string of the date in a given format
    /// - Parameter format: The format for the date
    /// - Returns: the date in the given format
    /// "dd/MM/yyyy" - 01/01/2000
    /// "HH:mm" - 13:14
    /// "LLLL" - January, February, Etc
    /// "EEEE" - Monday, Tuesday, Etc
    /// "E" - Mon, Tue, Etc
    func formatted(_ format: String, localeIdentifier: String = "en") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: localeIdentifier)
        return dateFormatter.string(from: self)
    }
    
    func timeIntervalSince(_ date: Date, withComponents components: Set<Calendar.Component>) -> TimeInterval? {
        let calendar = Calendar.current
        let untilDateComponents = calendar.dateComponents(components, from: date)
        let selfDateComponents = calendar.dateComponents(components, from: self)
        guard let compareDate = calendar.date(from: untilDateComponents) else { return nil }
        return calendar.date(from: selfDateComponents)?.timeIntervalSince(compareDate)
    }
  
    /// Returns a date with the same hours/minutes/seconds as this date but changes the day/month/year
    /// - Parameter date: the day/month/year to apply to the date
    func updateDateKeepingTime(_ date: Date = Date()) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.day = calendar.component(.day, from: date)
        components.month = calendar.component(.month, from: date)
        components.year = calendar.component(.year, from: date)
        components.hour = calendar.component(.hour, from: self)
        components.minute = calendar.component(.minute, from: self)
        components.second = calendar.component(.second, from: self)
        components.nanosecond = calendar.component(.nanosecond, from: self)
        return calendar.date(from: components) ?? self
    }
    
    /// Returns a date with the same day/month/year as this date but changes the hours/minutes/seconds/nanoseconds
    /// - Parameter date: the hours/minutes/seconds/nanoseconds to appl to this date
    func updateTimeKeepingDate(_ date: Date = Date()) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        
        components.day = calendar.component(.day, from: self)
        components.month = calendar.component(.month, from: self)
        components.year = calendar.component(.year, from: self)
        components.hour = calendar.component(.hour, from: date)
        components.minute = calendar.component(.minute, from: date)
        components.second = calendar.component(.second, from: date)
        components.nanosecond = calendar.component(.nanosecond, from: date)
        return calendar.date(from: components) ?? self
    }
    
    /// Returns Bool of dates being on same day
    /// 01/01/2000 & 02/01/2000 returns false as day is different
    /// - Parameter date: Date to compare with
    func isOnSameDay(asDate date: Date) -> Bool {
        return self.withComponents([.year, .month, .day]) == date.withComponents([.year, .month, .day])
    }
    
    /// Returns a date with only the provided Calendar Components
    /// - Parameter components: The components of the date to keep, any excluded value will be set to defaults
    func withComponents(_ components: Set<Calendar.Component>) -> Date {
        let calendar = Calendar.current
        let componentsWithoutSeconds = calendar.dateComponents(components, from: self)
        return calendar.date(from: componentsWithoutSeconds) ?? self
    }
}

// MARK: - Initialisers
public extension Date {
    init?(from dateString: String, format: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        guard let createdDate = dateFormatter.date(from: dateString) else { return nil }
        self = createdDate
    }
    
    init?(witnComponents components: Set<Calendar.Component>) {
        let calendar = Calendar.current
        let components = calendar.dateComponents(components, from: .now)
        guard let createdDate = calendar.date(from: components) else { return nil }
        self = createdDate
    }
}
