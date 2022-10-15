import Foundation

public extension TimeInterval {
    
    static var minuteInSeconds: TimeInterval = 60
    static var hourInSeconds: TimeInterval = 3600
    static var dayInSeconds: TimeInterval = hourInSeconds * 24
    static var weekInSeconds: TimeInterval = dayInSeconds * 7
    static var yearInSeconds: TimeInterval = weekInSeconds * 52
    
}
