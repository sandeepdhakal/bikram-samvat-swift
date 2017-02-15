//
//  BikramSamvatDate.swift
//  Pods
//
//  Created by Manjaro User on 2/15/17.
//
//

import Foundation

public class BikramSamvatDate {
    /// Bikram Samvat year.
    public let year: Int
    
    /// Bikram Samvat month (month numbers start from 1).
    public let month: Int
    
    /// Bikram Samvat day (day numbers start from 1).
    public let day: Int
    
    /// The Gregorian Date corresponding to this date.
    public lazy var gregorianDate: Date!  = {[unowned self] in
        return BikramSamvat.gregorianDate(fromBikramSamvatDate: self)
    }()
    
    public convenience init?() {
        guard let _date = BikramSamvat.bikramSamvatDate(fromGregorianDate: Date()) else {return nil}
        self.init(year: _date.year, month: _date.month, day: _date.day)
    }
    
    public init?(year: Int, month: Int, day: Int) {
        guard BikramSamvat.yearRange ~= year else {return nil}
        guard 1 ... 12 ~= month else {return nil}
        
        // we can explicitly unwrap the optional because year/month have already been checked above
        guard 1 ... BikramSamvat.numberOfDays(inYear: year, month: month)! ~= day else {return nil}
        
        self.year = year
        self.month = month
        self.day = day
    }
    
    /// Returns true if two BikramSamvatDate values represent the same point in time.
    ///
    /// - Parameters:
    ///   - first: the left hand date.
    ///   - second: the right hand date.
    /// - Returns: true if the two date values represent the same point in time, false otherwise.
    public static func ==(first: BikramSamvatDate, second: BikramSamvatDate) -> Bool {
        return (first.year == second.year) && (first.month == second.month) && (first.day == second.day)
    }
    
    /// Returns true if two BikramSamvatDate values don't represent the same point in time.
    ///
    /// - Parameters:
    ///   - first: the left hand date.
    ///   - second: the right hand date.
    /// - Returns: true if the two date values don't represent the same point in time.
    public static func !=(first: BikramSamvatDate, second: BikramSamvatDate) -> Bool {
        return !(first == second)
    }
    
    /// Returns true if the left BikramSamvatDate value is earlier than the right BikramSamvatDate.
    ///
    /// - Parameters:
    ///   - first: the left hand date.
    ///   - second: the right hand date.
    /// - Returns: true if the left BikramSamvatDate value is earlier than the right BikramSamvatDate.
    public static func <(first: BikramSamvatDate, second: BikramSamvatDate) -> Bool {
        if first.year < second.year {return true}
        if first.year == second.year {
            if first.month < second.month {return true}
            if first.month == second.month {return first.day < second.day}
        }
        return false
    }
    
    /// Returns true if the left BikramSamvatDate value is later than the right BikramSamvatDate.
    ///
    /// - Parameters:
    ///   - first: the left hand date.
    ///   - second: the right hand date.
    /// - Returns: true if the left BikramSamvatDate value is later than the right BikramSamvatDate.
    public static func >(first: BikramSamvatDate, second: BikramSamvatDate) -> Bool {
        if first.year > second.year {return true}
        if first.year == second.year {
            if first.month > second.month {return true}
            if first.month == second.month {return first.day > second.day}
        }
        return false
    }
    
    public static func >=(first: BikramSamvatDate, second: BikramSamvatDate) -> Bool {
        return first.compare(second) != .orderedAscending
    }
    
    public static func <=(first: BikramSamvatDate, second: BikramSamvatDate) -> Bool {
        return first.compare(second) == .orderedDescending
    }
    
    /// Compare two BikramSamvatDate values.
    ///
    /// - Parameter other: the date to compare this date with.
    /// - Returns: the comparison result of comparing this BikramSamvatDate value with the passed BikramSamvatDate value.
    public func compare(_ other: BikramSamvatDate) -> ComparisonResult {
        if self == other {return .orderedSame}
        if self < other {return .orderedAscending}
        return .orderedDescending
    }
}

extension BikramSamvatDate: CustomStringConvertible, CustomDebugStringConvertible {
    /// Date's description (year-month-day BS)
    public var description: String {
        return "\(year)-\(month)-\(day) BS"
    }
    
    /// Date's description (year-month-day BS)
    public var debugDescription: String {
        return "\(year)-\(month)-\(day) BS"
    }
}
