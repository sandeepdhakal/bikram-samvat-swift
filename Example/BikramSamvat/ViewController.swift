//
//  ViewController.swift
//  BikramSamvat
//
//  Created by sandeepdhakal on 02/15/2017.
//  Copyright (c) 2017 sandeepdhakal. All rights reserved.
//

import UIKit
import BikramSamvat

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        guard let today = BikramSamvatDate() else {
            print("Today is out of the supported range.")
            return
        }
        
        let todayGregorian = Date()
        if let todayBikramSamvat = BikramSamvat.bikramSamvatDate(fromGregorianDate: todayGregorian) {
            print(todayBikramSamvat)
            print(today == todayBikramSamvat)
        } else {
            print("Oops. Contact the developer -(")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

