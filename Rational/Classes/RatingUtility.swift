//
//  RatingUtility.swift
//  Rational
//
//  Created by Dolar, Ziga on 7/24/19.
//

import Foundation

import StoreKit

public final class RatingUtility {

    // MARK: Public interface

    public static func addMinorEvent() {
        shared.addEvent(.minor)
    }

    public static func addMajorEvent() {
        shared.addEvent(.major)
    }

    public static func configure(with minorEvents: Int = 10,
                                 majorEvents: Int = 3,
                                 minDaysSinceUpdateOrRequest: Int = 5,
                                 minLaunchCount: Int = 3) {
        shared.configure(with: minorEvents,
                         majorEvents: majorEvents,
                         minDaysSinceUpdateOrRequest: minDaysSinceUpdateOrRequest,
                         minLaunchCount: minLaunchCount)
    }

    // MARK: Private - utility internals

    private enum EventType: CaseIterable {
        case minor, major

        var countKey: String {
            switch self {
            case .minor:
                return RatingUtility.minorEventsCountKey
            case .major:
                return RatingUtility.majorEventsCountKey
            }
        }
    }

    private static let lastVersionKey = "kRatingUtilityLastVersionKey"
    private static let versionUpdatedDateKey = "kRatingUtilityVersionUpdatedDateKey"
    private static let versionLaunchCountKey = "kRatingUtilityVersionLaunchCountKey"

    private static let firstRequestDateKey = "kRatingUtilityFirstRequestDateKey"
    private static let requestsCountKey = "kRatingUtilityRequestsCountKey"

    private static let lastRequestDateKey = "kRatingUtilityLastRequestDateKey"

    private static let minorEventsCountKey = "kRatingUtilityMinorEventsCountKey"
    private static let majorEventsCountKey = "kRatingUtilityMajorEventsCountKey"

    private static let shared = {
        return RatingUtility()
    }()

    private let defaults: UserDefaults

    private var minorEventsNeeded: Int = 10
    private var majorEventsNeeded: Int = 3
    private var minDaysSinceUpdateOrRequest: Int = 5
    private var minLaunchCount: Int = 3

    private init(_ defaults: UserDefaults = .standard) {
        self.defaults = defaults

        incrementVersionLaunchCount()
        checkVersionChange()
        resetRequestsCountIfNeeded()
    }

    private func configure(with minorEvents: Int = 10,
                           majorEvents: Int = 3,
                           minDaysSinceUpdateOrRequest: Int = 5,
                           minLaunchCount: Int = 3) {
        self.minorEventsNeeded = minorEvents
        self.majorEventsNeeded = majorEvents
        self.minDaysSinceUpdateOrRequest = minDaysSinceUpdateOrRequest
        self.minLaunchCount = minLaunchCount
    }

    private func checkVersionChange() {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return
        }

        let lastVersion = defaults.string(forKey: RatingUtility.lastVersionKey)
        guard version != lastVersion else {
            return
        }

        defaults.set(version, forKey: RatingUtility.lastVersionKey)
        defaults.set(Date(), forKey: RatingUtility.versionUpdatedDateKey)

        resetEvents()
        resetVersionLaunchCount()
    }

    private func addEvent(_ event: EventType) {
        increment(event)

        requestReviewIfNeeded()
    }

    private func increment(_ event: EventType) {
        let countKey = event.countKey
        let count = defaults.integer(forKey: countKey) + 1

        defaults.set(count, forKey: countKey)
    }

    private func resetEvents() {
        EventType.allCases.forEach { defaults.set(0, forKey: $0.countKey) }
    }

    private func incrementVersionLaunchCount() {
        let countKey = RatingUtility.versionLaunchCountKey
        let count = defaults.integer(forKey: countKey) + 1

        defaults.set(count, forKey: countKey)
    }

    private func resetVersionLaunchCount() {
        defaults.set(1, forKey: RatingUtility.versionLaunchCountKey)
    }

    private func requestReviewIfNeeded() {
        guard shouldRequestReview else {
            return
        }

        incrementRequestsCount()
        resetEvents()

        SKStoreReviewController.requestReview()
    }

    private func incrementRequestsCount() {
        let countKey = RatingUtility.requestsCountKey
        let count = defaults.integer(forKey: countKey) + 1

        defaults.set(count, forKey: countKey)

        let requestDate = Date()

        defaults.set(requestDate, forKey: RatingUtility.lastRequestDateKey)

        guard defaults.object(forKey: RatingUtility.firstRequestDateKey) as? Date == nil else {
            return
        }

        defaults.set(requestDate, forKey: RatingUtility.firstRequestDateKey)
    }

    private func resetRequestsCountIfNeeded() {
        guard let firstRequestDate = defaults.object(forKey: RatingUtility.firstRequestDateKey) as? Date,
            firstRequestDate.fullDaysUntilNow >= 365 else {
                return
        }

        defaults.set(nil, forKey: RatingUtility.firstRequestDateKey)
        defaults.set(0, forKey: RatingUtility.requestsCountKey)
    }

    private var shouldRequestReview: Bool {
        let updateDate = defaults.object(forKey: RatingUtility.versionUpdatedDateKey) as? Date ?? Date()

        guard updateDate.fullDaysUntilNow >= minDaysSinceUpdateOrRequest else {
            return false
        }

        let lastRequestDate = defaults.object(forKey: RatingUtility.lastRequestDateKey) as? Date ?? Date(timeIntervalSince1970: 0)
        guard lastRequestDate.fullDaysUntilNow >= minDaysSinceUpdateOrRequest else {
            return false
        }

        let launchCount = defaults.integer(forKey: RatingUtility.versionLaunchCountKey)

        guard launchCount >= minLaunchCount else {
            return false
        }

        let requestsCount = defaults.integer(forKey: RatingUtility.requestsCountKey)

        guard requestsCount < 3 else {
            return false
        }

        let minorEventsCount = defaults.integer(forKey: EventType.minor.countKey)
        let majorEventsCount = defaults.integer(forKey: EventType.major.countKey)

        return minorEventsCount >= minorEventsNeeded || majorEventsCount >= majorEventsNeeded
    }
}
