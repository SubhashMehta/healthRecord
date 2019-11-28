//
//  ViewController.swift
//  HealthData_Demo
//
//  Created by Shubash Kumar on 11/2/18.
//  Copyright © 2018 Shubash Kumar. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController,HealthKitInstanceMethodsProtocol {
    let healthStore = HKHealthStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        HealthKitInstance.shared.delegate = self
    }
   
    @IBAction func actionForGetData(_ sender: Any) {

        //Pass value according to which value you want to fetch:--
        //Steps = "Steps"
        //Walking Distance = "Walking"
        //Gender = "Gender"
        //Weight = "Weight"
        HealthKitInstance.shared.authoriseHealthKitAccess(value: "Steps")
    }
    func saveHealthDataSuccessfully(dict: Dictionary<String, Any>) {
        print(dict)
    }
}


