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
       // self.authoriseHealthKitAccess()
        HealthKitInstance.shared.delegate = self
    }
    
    func authoriseHealthKitAccess()  {
//        let healthKitTypes: Set<HKObjectType> = [
//            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
//            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
//            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
//            
//            ]
        
        let healthKitTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!, HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!
        ]
        
        
        
        healthStore.requestAuthorization(toShare: nil, read: healthKitTypes ) { (bool, error) in
            if let e = error{
                print("Oops Something went wrong during getting permission...")
            }else{
                print("User has completed athorization flow...")
            }
        }
    }
  
    private let healthStore1 = HKHealthStore()
    private let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    
    func getStepsCounts() {
        let now = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -3, to: now)!
        
        var interval = DateComponents()
        interval.day = 0
        interval.hour = 0
        interval.minute = 10
        
        var anchorComponents = Calendar.current.dateComponents([.minute, .hour, .day, .month, .year], from: now)
        // anchorComponents.hour = 1
        anchorComponents.minute = 10
        let anchorDate = Calendar.current.date(from: anchorComponents)!
        
        let query = HKStatisticsCollectionQuery(quantityType: stepsQuantityType,
                                                quantitySamplePredicate: nil,
                                                options: [.cumulativeSum],
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        query.initialResultsHandler = { _, results, error in
            guard let results = results else {
                //  log.error("Error returned form resultHandler = \(String(describing: error?.localizedDescription))")
                return
            }
            var i:Int = 0
            results.enumerateStatistics(from: startDate, to: now) { statistics, _ in
                if let sum = statistics.sumQuantity() {
                    let steps = sum.doubleValue(for: HKUnit.count())
                    print("Amount of steps: \(sum), date: \(statistics.startDate)")
                    i = i + 1
                    print("Counts:--\(i)")
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    /*
    func getWalkingDistance(completion: @escaping (Double) -> Void) {
        let now = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -3, to: now)!
        
        var interval = DateComponents()
        interval.day = 0
        interval.hour = 0
        interval.minute = 10
        let stepsQuantityType1 = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        var anchorComponents = Calendar.current.dateComponents([.minute, .hour, .day, .month, .year], from: now)
        // anchorComponents.hour = 1
        anchorComponents.minute = 10
        let anchorDate = Calendar.current.date(from: anchorComponents)!
        
        let query = HKStatisticsCollectionQuery(quantityType: stepsQuantityType1,
                                                quantitySamplePredicate: nil,
                                                options: [.cumulativeSum],
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        query.initialResultsHandler = { _, results, error in
            guard let results = results else {
                //  log.error("Error returned form resultHandler = \(String(describing: error?.localizedDescription))")
                return
            }
            var i:Int = 0
            results.enumerateStatistics(from: startDate, to: now) { statistics, _ in
                if let sum = statistics.sumQuantity() {
                    let steps = sum.doubleValue(for: HKUnit.mile())
                    let meter = sum.doubleValue(for: HKUnit.meter())
                    print("Amount of steps: \(sum), date: \(statistics.startDate) , Miles: \(steps)")
                    i = i + 1
                    
                    print("Meter:--\(meter) , Counts:-\(i)")
                    
                    //                    let distance = Double(sum)
                    //                    let finalKilometers = sum.converted(to: .kilometers) // 1.005 km
                    //                    let finalMeters = sum.converted(to: .meters) // 1005.0 m
                    //                    let finalMiles = sum.converted(to: .miles) // 0.6224 mi
                    
                    
                }
            }
        }
        
        healthStore.execute(query)
    }
    
   */
    
   
    @IBAction func actionForGetData(_ sender: Any) {
        
        
        
//        //Get Walking Distance
//        self.getWalkingDistance { (result) in
//                   // print("\(result)")
//                    DispatchQueue.main.async {
//                      //  print("\(result)")
//                        //self.totalSteps.text = "\(result)"
//                    }
//                }
        //Get Steps Count:--
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


