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
        
        let today = BikramSamvat.today()
        print(today)
        
        let todayGregorian = Date()
        if let todayBikramSamvat = BikramSamvat.bikramSambatDate(fromGregorianDate: todayGregorian) {
            print(todayBikramSamvat)
            print(today == todayBikramSamvat)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

