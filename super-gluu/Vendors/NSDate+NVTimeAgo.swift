//  NSDate+NVTimeAgo.swift
//  Adventures
//
//  Created by Nikil Viswanathan on 4/18/13.
//  Copyright (c) 2013 Nikil Viswanathan. All rights reserved.
//
import UIKit


struct Time {
    static let SECOND = 1
    static let MINUTE = SECOND * 60
    static let HOUR = MINUTE * 60
    static let DAY = HOUR * 24
    static let WEEK = DAY * 7
    static let MONTH = DAY * 31
    static let YEAR = DAY * 365
}

extension Date {


    
    /*
        Mysql Datetime Formatted As Time Ago
        Takes in a mysql datetime string and returns the Time Ago date format
     */
    
    /*
    class func mysqlDatetimeFormatted(asTimeAgo mysqlDatetime: String?) -> String? {
        //http://stackoverflow.com/questions/10026714/ios-converting-a-date-received-from-a-mysql-server-into-users-local-time
        //If this is not in UTC, we don't have any knowledge about
        //which tz it is. MUST BE IN UTC.
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let date: Date? = formatter.date(from: mysqlDatetime ?? "")

        return date?.formattedAsTimeAgo()

    }
 */

    /*
     =======================================================================
     */





    /*
     ========================== Test Method ==========================
     */

    /*
        Test the format
        TODO: Implement unit tests
     */
    /*
    class func runTests() {
        print("1 Second in the future: \(Date(timeIntervalSinceNow: 1).formattedAsTimeAgo())\n")
        print("Now: \(Date(timeIntervalSinceNow: 0).formattedAsTimeAgo())\n")
        print("1 Second: \(Date(timeIntervalSinceNow: -1).formattedAsTimeAgo())\n")
        print("10 Seconds: \(Date(timeIntervalSinceNow: -10).formattedAsTimeAgo())\n")
        print("1 Minute: \(Date(timeIntervalSinceNow: -60).formattedAsTimeAgo())\n")
        print("2 Minutes: \(Date(timeIntervalSinceNow: -120).formattedAsTimeAgo())\n")
        print("1 Hour: \(Date(timeIntervalSinceNow: TimeInterval(-HOUR)).formattedAsTimeAgo())\n")
        print("2 Hours: \((Date(timeIntervalSinceNow: TimeInterval(-2 * HOUR))).formattedAsTimeAgo())\n")
        print("1 Day: \((Date(timeIntervalSinceNow: TimeInterval(-1 * DAY))).formattedAsTimeAgo())\n")
        print("1 Day + 3 seconds: \((Date(timeIntervalSinceNow: TimeInterval(-1 * DAY - 3))).formattedAsTimeAgo())\n")
        print("2 Days: \((Date(timeIntervalSinceNow: TimeInterval(-2 * DAY))).formattedAsTimeAgo())\n")
        print("3 Days: \((Date(timeIntervalSinceNow: TimeInterval(-3 * DAY))).formattedAsTimeAgo())\n")
        print("5 Days: \((Date(timeIntervalSinceNow: TimeInterval(-5 * DAY))).formattedAsTimeAgo())\n")
        print("6 Days: \((Date(timeIntervalSinceNow: TimeInterval(-6 * DAY))).formattedAsTimeAgo())\n")
        print("7 Days - 1 second: \((Date(timeIntervalSinceNow: TimeInterval(-7 * DAY + 1))).formattedAsTimeAgo())\n")
        print("10 Days: \((Date(timeIntervalSinceNow: TimeInterval(-10 * DAY))).formattedAsTimeAgo())\n")
        print("1 Month + 1 second: \((Date(timeIntervalSinceNow: TimeInterval(-MONTH - 1))).formattedAsTimeAgo())\n")
        print("1 Year - 1 second: \((Date(timeIntervalSinceNow: TimeInterval(-YEAR + 1))).formattedAsTimeAgo())\n")
        print("1 Year + 1 second: \((Date(timeIntervalSinceNow: TimeInterval(-YEAR + 1))).formattedAsTimeAgo())\n")
    }
 */

    /*
        Formatted As Time Ago
        Returns the date formatted as Time Ago (in the style of the mobile time ago date formatting for Facebook)
     */
    func formattedAsTimeAgo() -> String? {
        //Now
        let now = Date()
        let secondsSince = -Int(timeIntervalSince(now))

        //Should never hit this but handle the future case
        if secondsSince < 0 {
            return "In The Future"
        }


        // < 1 minute = "Just now"
        if secondsSince < Time.MINUTE {
            return "Just now"
        }


        // < 1 hour = "x minutes ago"
        if secondsSince < Time.HOUR {
            return formatMinutesAgo(secondsSince)
        }


        // Today = "x hours ago"
        if isSameDay(as: now) {
            return format(asToday: secondsSince)
        }


        // Yesterday = "Yesterday at 1:28 PM"
        if isYesterday(now) {
            return formatAsYesterday()
        }


        // < Last 7 days = "Friday at 1:48 AM"
        if isLastWeek(secondsSince) {
            return formatAsLastWeek()
        }


        // < Last 30 days = "March 30 at 1:14 PM"
        if isLastMonth(secondsSince) {
            return formatAsLastMonth()
        }

        // < 1 year = "September 15"
        if isLastYear(secondsSince) {
            return formatAsLastYear()
        }

        // Anything else = "September 9, 2011"
        return formatAsOther()

    }

    /*
     ========================== Date Comparison Methods ==========================
     */

    /*
        Is Same Day As
        Checks to see if the dates are the same calendar day
     */
    func isSameDay(as comparisonDate: Date?) -> Bool {
        //Check by matching the date strings
        let dateComparisonFormatter = DateFormatter()
        dateComparisonFormatter.dateFormat = "yyyy-MM-dd"

        //Return true if they are the same
        if let aDate = comparisonDate {
            return (dateComparisonFormatter.string(from: self as Date)) == dateComparisonFormatter.string(from: aDate)
        }
        return false
    }

    /*
     If the current date is yesterday relative to now
     Pasing in now to be more accurate (time shift during execution) in the calculations
     */
    func isYesterday(_ now: Date?) -> Bool {
        return isSameDay(as: now?.date(bySubtractingDays: 1))
    }

    //From https://github.com/erica/NSDate-Extensions/blob/master/NSDate-Utilities.m
    func date(bySubtractingDays numDays: Int) -> Date? {
        
        let aTimeInterval = TimeInterval(Int(timeIntervalSinceReferenceDate) + Time.DAY * -numDays)
        let newDate = Date(timeIntervalSinceReferenceDate: aTimeInterval)
        return newDate
    }

    /*
        Is Last Week
        We want to know if the current date object is the first occurance of
        that day of the week (ie like the first friday before today 
        - where we would colloquially say "last Friday")
        ( within 6 of the last days)
     
        TODO: make this more precise (1 week ago, if it is 7 days ago check the exact date)
     */
    func isLastWeek(_ secondsSince: Int) -> Bool {
        return secondsSince < Time.WEEK
    }

    /*
        Is Last Month
        Previous 31 days?
        TODO: Validate on fb
        TODO: Make last day precise
     */
    func isLastMonth(_ secondsSince: Int) -> Bool {
        return secondsSince < Time.MONTH
    }

    /*
        Is Last Year
        TODO: Make last day precise
     */
    func isLastYear(_ secondsSince: Int) -> Bool {
        return secondsSince < Time.YEAR
    }

    /*
     =============================================================================
     */





    /*
       ========================== Formatting Methods ==========================
     */


    // < 1 hour = "x minutes ago"
    func formatMinutesAgo(_ secondsSince: Int) -> String? {
        //Convert to minutes
        let minutesSince = Int(secondsSince) / Time.MINUTE

        //Handle Plural
        if minutesSince == 1 {
            return "1m ago"
        } else {
            return "\(minutesSince)m ago"
        }
    }

    // Today = "x hours ago"
    func format(asToday secondsSince: Int) -> String? {
        //Convert to hours
        let hoursSince = Int(secondsSince) / Time.HOUR

        //Handle Plural
        if hoursSince == 1 {
            return "1h ago"
        } else {
            return "\(hoursSince)h ago"
        }
    }

    // Yesterday = "Yesterday at 1:28 PM"
    func formatAsYesterday() -> String? {
        //Create date formatter
        let dateFormatter = DateFormatter()

        //Format
        dateFormatter.dateFormat = "h:mm a"
        return LocalString.Yesterday.localized + " at \(dateFormatter.string(from: self as Date))"
    }

    // < Last 7 days = "Friday at 1:48 AM"
    func formatAsLastWeek() -> String? {
        //Create date formatter
        let dateFormatter = DateFormatter()

        //Format
        dateFormatter.dateFormat = "EEEE 'at' h:mm a"
        return dateFormatter.string(from: self as Date)
    }

    // < Last 30 days = "March 30 at 1:14 PM"
    func formatAsLastMonth() -> String? {
        //Create date formatter
        let dateFormatter = DateFormatter()

        //Format
        dateFormatter.dateFormat = "MMMM d 'at' h:mm a"
        return dateFormatter.string(from: self as Date)
    }

    // < 1 year = "September 15"
    func formatAsLastYear() -> String? {
        //Create date formatter
        let dateFormatter = DateFormatter()

        //Format
        dateFormatter.dateFormat = "MMMM d"
        return dateFormatter.string(from: self as Date)
    }

    // Anything else = "September 9, 2011"
    func formatAsOther() -> String? {
        //Create date formatter
        let dateFormatter = DateFormatter()

        //Format
        dateFormatter.dateFormat = "LLLL d, yyyy"
        return dateFormatter.string(from: self as Date)
    }
    /*
     =======================================================================
     */



}
