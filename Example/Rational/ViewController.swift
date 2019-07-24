//
//  ViewController.swift
//  Rational
//
//  Created by Dolar, Ziga on 07/24/2019.
//  Copyright (c) 2019 Dolar, Ziga. All rights reserved.
//

import UIKit

import Rational

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        RatingUtility.configure(with: 3, majorEvents: 5, minDaysSinceUpdateOrRequest: 0, minLaunchCount: 3)

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            RatingUtility.addMinorEvent()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            RatingUtility.addMajorEvent()
        }
    }
}

