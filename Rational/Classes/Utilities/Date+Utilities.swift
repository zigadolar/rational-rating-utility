//
//  Date+Utilities.swift
//  Rational
//
//  Created by Dolar, Ziga on 7/24/19.
//

import Foundation

extension Date {
    var fullDaysUntilNow:Int {
        return Int((timeIntervalSinceNow * (-1)) / 3600 / 24)
    }
}
