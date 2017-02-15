//
//  BikramSamvatExtension.swift
//  Pods
//
//  Created by Manjaro User on 2/15/17.
//
//

import Foundation

public extension BikramSamvat {
    /// Returns the number of days in the given Bikram Sambat year and month. Returns nil if the year and month are outside the calendar's range.
    ///
    /// - Parameters:
    ///   - year: Bikram Sambat year
    ///   - month: Bikram Sambat month in the range 1...12
    /// - Returns: Number of days in the given year and month, nil if year and month are outside the calendar's range.
    public static func numberOfDays(inYear year: Int, month: Int) -> Int? {
        guard yearRange ~= year else {return nil}
        guard 1...12 ~= month else {return nil}
        
        let yearIndex = year - yearRange.lowerBound
        return numberOfDaysInMonths[yearIndex][month - 1]
    }
    
    public static func gregorianMonthsAndYear(forYear year: Int, andMonth month: Int) -> String? {
        guard yearRange ~= year else {return nil}
        guard 1...12 ~= month else {return nil}
        
        let gregorianCalendar = Calendar(identifier: .gregorian)
        let (startMonth, endMonth) = gregorianMonthRanges[month - 1]
        let startMonthName = DateFormatter().shortMonthSymbols[startMonth - 1]
        let endMonthName = DateFormatter().shortMonthSymbols[endMonth - 1]
        
        let date = BikramSamvatDate(year: year, month: month, day: 20)!
        let gregorianYear: Int = gregorianCalendar.component(.year, from: date.gregorianDate)
        return "\(startMonthName)/\(endMonthName) \(gregorianYear)"
    }
    
    /// Bikram Samvat date for today.
    ///
    /// - Returns: Bikram Samvat date for today.
    public static func today() -> BikramSamvatDate {
        return bikramSambatDate(fromGregorianDate: Date())!
    }
    
    /// Converts date from Bikram Samvat calendar to Gregorian calendar.
    ///
    /// - Parameter date: date in Bikram Samvat calendar
    /// - Returns: date in Gregorian calendar
    public static func gregorianDate(fromBikramSamvatDate date: BikramSamvatDate) -> Date? {
        let yearIndex = date.year - yearRange.lowerBound
        let dayOfYear = firstDayOfBSMonth[yearIndex][date.month - 1]
        let gregorianYear = date.year - (dayOfYear > 100 ? 57 : 56)
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar(identifier: .gregorian)
        dateComponents.timeZone = timezone
        dateComponents.year = gregorianYear
        dateComponents.month = 1
        dateComponents.day = dayOfYear + (date.day - 1)
        
        return dateComponents.date
    }
    
    /// Converts date from Gregorian calendar to BikramSamvat calendar. Returns nil if the date in Gregorian calendar is outside the supported range.
    ///
    /// - Parameter date: date in Gregorian calendar.
    /// - Returns: date in BikramSamvat calendar.
    public static func bikramSambatDate(fromGregorianDate date: Date) -> BikramSamvatDate? {
        // convert gregorian date to NPT
        let components = Calendar(identifier: .gregorian).dateComponents(in: timezone, from: date)
        let dayOfGregorianYear = Calendar(identifier: .gregorian).ordinality(of: .day, in: .year, for: date)!
        let month = components.month!
        
        var estimatedYear = components.year! + 56
        let (startMonth, endMonth) = bikramSamvatMonthRanges[month - 1]
        var startDay = firstGregorianDay(ofBikramSamvatYear: estimatedYear, andMonth: startMonth)!
        var endDay = firstGregorianDay(ofBikramSamvatYear: estimatedYear, andMonth: endMonth)!
        
        if month == 1 {
            if dayOfGregorianYear >= endDay {
                return BikramSamvatDate(year: estimatedYear, month: endMonth, day: (dayOfGregorianYear - endDay + 1))
            }
            
            let year = components.year! - 1
            let isLeapYear = ((year % 100 != 0) && (year % 4 == 0)) || year % 400 == 0
            let day = (isLeapYear ? 366 : 365) - startDay + dayOfGregorianYear + 1
            
            return BikramSamvatDate(year: estimatedYear, month: startMonth, day: day)
        }
        
        if month == 4 {         // April, could either be this year or next year
            endDay = firstGregorianDay(ofBikramSamvatYear: estimatedYear + 1, andMonth: endMonth)!
            if endDay <= dayOfGregorianYear {
                estimatedYear += 1
            }
        } else if month > 4 {   // next year
            estimatedYear += 1
            startDay = firstGregorianDay(ofBikramSamvatYear: estimatedYear, andMonth: startMonth)!
            endDay = firstGregorianDay(ofBikramSamvatYear: estimatedYear, andMonth: endMonth)!
        }
        
        let bikramSamvatDay = dayOfGregorianYear + 1 - (dayOfGregorianYear >= endDay ? endDay : startDay)
        let bikramSamvatMonth = (dayOfGregorianYear >= endDay) ? endMonth : startMonth
        return BikramSamvatDate(year: estimatedYear, month: bikramSamvatMonth, day: bikramSamvatDay)
    }
    
    /// Returns the day of year (in Gregorian Calendar) corresponding to the 1st day of the specified BikramSamvat month and year.
    ///
    /// - Parameters:
    ///   - year: the BikramSamvat year for which the 1st day of month has to be returned.
    ///   - month: the BikramSamvat month, for whose 1st day, the corresponding day of Gregorian calendar year has to be returned.
    /// - Returns: the day of year (in Gregorian Calendar) corresponding to the 1st day of the specified BikramSamvat month and year. Returns nil if the BikramSamvat year and month are outside of the supported range.
    private static func firstGregorianDay(ofBikramSamvatYear year: Int, andMonth month: Int) -> Int? {
        guard yearRange ~= year else {return nil}
        guard 1 ... 12 ~= month else {return nil}
        
        let yearIndex = year - yearRange.lowerBound
        return firstDayOfBSMonth[yearIndex][month - 1]
    }
    
    /// Returns whether the specified year is a leap year.
    ///
    /// - Parameter year: the year which is to be checked.
    /// - Returns: whether the specified year is a leap year.
    public static func isLeapYear(_ year: Int) -> Bool? {
        guard yearRange ~= year else {return nil}
        let yearIndex = year - yearRange.lowerBound
        return numberOfDaysInMonths[yearIndex].reduce(0, +) == 366
    }
    
    /// The number of days/months/years between the from date and to date.
    ///
    /// - Parameters:
    ///   - component: the difference in terms of this component
    ///   - from: the starting date for the calculation
    ///   - to: the end date for the calculation.
    /// - Returns: the number of days/months/years between the two dates.
    public static func component(_ component: Component, fromDate from: BikramSamvatDate, toDate to: BikramSamvatDate) -> DateComponents {
        var from = from
        var to = to
        if from > to {
            swap(&from, &to)
        }
        
        var components = DateComponents()
        
        var years = to.year - from.year
        if dayOfYear(forDate: to) < dayOfYear(forDate: from) {
            years -= 1
        }
        
        if component == .year {
            components.year = years
            return components
        } else {
            var months = years * 12
            months += (dayOfYear(forDate: to) >= dayOfYear(forDate: from)) ? (to.month - from.month) : (12 - from.month + to.month)
            if (numberOfDays(inYear: to.year, month: to.month)! - to.day) > (numberOfDays(inYear: from.year, month: from.month)! - from.month) {
                months -= 1
            }
            if component == .month {
                components.month = months
                return components
            }
            
            var days = 0
            if to.year == from.year { // same year
                days = dayOfYear(forDate: to) - dayOfYear(forDate: from)
            } else {
                days = (isLeapYear(from.year)! ? 366 : 365) - dayOfYear(forDate: from)
                days += dayOfYear(forDate: to)
                
                for year in (from.year + 1) ..< to.year {
                    days += isLeapYear(year)! ? 366 : 365
                }
            }
            components.day = days
            return components
        }
    }
    
    public static func components(components: [Component], fromDate from: BikramSamvatDate, toDate to: BikramSamvatDate) -> DateComponents {
        var from = from
        var to = to
        if from > to {
            swap(&from, &to)
        }
        var differenceComponents = DateComponents()
        var years = 0
        var months = 0
        
        if components.contains(.year) {
            years = component(.year, fromDate: from, toDate: to).year!
            differenceComponents.year = years
        }
        if components.contains(.month) {
            months = component(.month, fromDate: from, toDate: to).month!
            if components.contains(.year) {
                months -= (years * 12)
            }
            differenceComponents.month = months
        }
        if components.contains(.day) {
            let fromDate = date(byAdding: differenceComponents, to: from)!
            differenceComponents.day = component(.day, fromDate: fromDate, toDate: to).day!
        }
        
        return differenceComponents
    }
    
    /// The day of the year for the provided date.
    ///
    /// - Parameter date: the date for which the day of the year has to be calculated.
    /// - Returns: the day of the year.
    public static func dayOfYear(forDate date: BikramSamvatDate) -> Int {
        return numberOfDaysInMonths[date.year - yearRange.lowerBound][0 ..< date.month - 1].reduce(date.day, +)
    }
    
    public static func date(byAdding: DateComponents, to: BikramSamvatDate) -> BikramSamvatDate? {
        // increment year and ensure its within range
        var nextYear = to.year
        if let years = byAdding.year, years > 0 {
            nextYear = to.year + years
            guard yearRange ~= nextYear else {return nil}
        }
        
        // add months and also year from months
        var nextMonth = to.month
        if let months = byAdding.month, months > 0 {
            nextYear += (months / 12)
            nextMonth += (months % 12)
            
            if nextMonth > 12 {
                nextYear += 1
                nextMonth -= 12
            }
            guard yearRange ~= nextYear else {return nil}
        }
        
        // add days
        let daysToAdd = to.day + (byAdding.day ?? 0) - 1
        guard let nextDate = BikramSamvatDate(year: nextYear, month: nextMonth, day: 1) else {return nil}
        return add(days: daysToAdd, toDate: nextDate)
    }
    
    /// Return a new date by adding the specified number of days to the provided date.
    ///
    /// - Parameters:
    ///   - days: number of days to add.
    ///   - date: the date to which days are to be added.
    /// - Returns: new date after adding the specified number of days to the provided date, nil if date is outside the supported range.
    public static func add(days: Int, toDate date: BikramSamvatDate) -> BikramSamvatDate? {
        var daysToAdd = days
        let daysInYear = isLeapYear(date.year)! ? 366 : 365
        let _dayOfYear = dayOfYear(forDate: date)
        
        if (_dayOfYear + daysToAdd) > daysInYear {
            guard let newYearNextYear = BikramSamvatDate(year: date.year + 1, month: 1, day: 1) else {return nil}
            daysToAdd = _dayOfYear + daysToAdd - daysInYear - 1
            return add(days: daysToAdd, toDate: newYearNextYear)
        }
        
        let daysInMonth = numberOfDays(inYear: date.year, month: date.month)!
        if (date.day + daysToAdd) > daysInMonth {
            daysToAdd = date.day + daysToAdd - daysInMonth - 1
            if date.month == 12 {
                guard let newDayNextYear = BikramSamvatDate(year: date.year + 1, month: 1, day: 1) else {return nil}
                return add(days: daysToAdd, toDate: newDayNextYear)
            } else {
                let dateNextMonth = BikramSamvatDate(year: date.year, month: date.month + 1, day: 1)!
                return add(days: daysToAdd, toDate: dateNextMonth)
            }
        } else {
            return BikramSamvatDate(year: date.year, month: date.month, day: date.day + daysToAdd)
        }
    }
    
    public enum Component {
        case year, month, day
    }
}
