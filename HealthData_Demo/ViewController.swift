//
//  ViewController.swift
//  HealthData_Demo
//
//  Created by Shubash Kumar on 11/2/18.
//  Copyright © 2018 Shubash Kumar. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    let healthStore = HKHealthStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.authoriseHealthKitAccess()
    }
    
    func authoriseHealthKitAccess()  {
        let healthKitTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
            
            ]

        healthStore.requestAuthorization(toShare: nil, read: healthKitTypes ) { (bool, error) in
            if let e = error{
                print("Oops Something went wrong during getting permission...")
            }else{
                print("User has completed athorization flow...")
            }
        }
    }
    
    func callingFunction()  {
        let calendar = NSCalendar.current
        
        let interval = NSDateComponents()
        interval.day = 7
        
        // Set the anchor date to Monday at 3:00 a.m.
        var anchorComponents = Calendar.current.dateComponents([.day, .month, .year, .weekday], from: Date())
        
      //  let anchorComponents = calendar.components([.Day, .Month, .Year, .Weekday], fromDate: NSDate())
        
        
        let offset = (7 + anchorComponents.weekday! - 2) % 7
        anchorComponents.day = offset
       // anchorComponents.day -= offset
        anchorComponents.hour = 3
        
        guard let anchorDate = calendar.date(from: anchorComponents) else {
             fatalError("*** unable to create a valid date from the given components ***")
        }
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) else {
            fatalError("*** Unable to create a step count type ***")
        }
        
        // Create the query
        let query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval as DateComponents)
        
        // Set the results handler
        query.initialResultsHandler = {
            query, results, error in
            
            guard let statsCollection = results else {
                // Perform proper error handling here
                fatalError("*** An error occurred while calculating the statistics: \(error?.localizedDescription) ***")
            }
            
            let endDate = NSDate()
            guard let startDate = calendar.date(byAdding: .month, value: -3, to: endDate as Date) else {
                fatalError("*** Unable to calculate the start date ***")
            }
            
           
            
            // Plot the weekly step counts over the past 3 months
            statsCollection.enumerateStatistics(from: startDate, to: Date()) { [unowned self] statistics, stop in
                
                if let quantity = statistics.sumQuantity() {
                    let date = statistics.startDate
                    let value = quantity.doubleValue(for: HKUnit.count())
                    print("Amount of steps: \(value), date: \(statistics.startDate)")
                    // Call a custom method to plot each data point.
                   // self.plotWeeklyStepCount(value, forDate: date)
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    
    
    
    private let healthStore1 = HKHealthStore()
    private let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    
    func importStepsHistory() {
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
    func getTodaysSteps123(completion: @escaping (Double) -> Void) {
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
    
    func retrieveStepCount(completion: @escaping (_ stepRetrieved: Double) -> Void) {
        
        //   Define the Step Quantity Type
        let stepsCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        //   Get the start of the day
        let date = Date()
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let newDate = cal.startOfDay(for: date)
        
        //  Set the Predicates & Interval
        let predicate = HKQuery.predicateForSamples(withStart: newDate, end: Date(), options: .strictStartDate)
        var interval = DateComponents()
        interval.day = 1
        
        //  Perform the Query
        let query = HKStatisticsCollectionQuery(quantityType: stepsCount!, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: newDate as Date, intervalComponents:interval)
        
        query.initialResultsHandler = { query, results, error in
            if error != nil {
                //  Something went Wrong
                return
            }
             let yesterday = Calendar.current.date(byAdding: .day, value: 0, to: Date())
            if let myResults = results{
                myResults.enumerateStatistics(from: yesterday!, to: Date()) {
                    statistics, stop in
                    if let quantity = statistics.sumQuantity() {
                        let steps = quantity.doubleValue(for: HKUnit.count())
                        print("Steps = \(steps)")
                        completion(steps)
                    }
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    
    func getTodaysSteps(completion: @escaping (Double) -> Void) {
        
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!
        
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -7, to: Date())

        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: yesterday , end: Date(), options: .strictEndDate)
        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            var resultCount:Double = 0
            guard let result = result else {
                print("Failed to fetch steps rate")
                completion(resultCount)
                return
            }
            
            if let sum = result.sumQuantity() {
                resultCount = sum.doubleValue(for: HKUnit.count())
            }
            DispatchQueue.main.async {
                completion(resultCount)
            }
        }
        healthStore.execute(query)
    }
    @IBAction func actionForGetData(_ sender: Any) {
//        getTodaysSteps123 { (result) in
//           // print("\(result)")
//            DispatchQueue.main.async {
//              //  print("\(result)")
//                //self.totalSteps.text = "\(result)"
//            }
//        }
        self.importStepsHistory()
    }
}


