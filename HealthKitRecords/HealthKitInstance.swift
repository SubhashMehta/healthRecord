//
//  HealthKitInstance.swift
//  InchoraApp
//
//  Created by Shubash Kumar on 12/24/18.
//  Copyright © 2018 Subhash Kumar. All rights reserved.
//

import UIKit
import Foundation
import HealthKit

@objc protocol HealthKitInstanceMethodsProtocol{
    @objc optional func saveHealthDataSuccessfully(dict:Dictionary<String,Any>)->Void
    
}

class HealthKitInstance: NSObject {
    
    let healthStore = HKHealthStore()
    static let shared = HealthKitInstance()
    var delegate:HealthKitInstanceMethodsProtocol?
    var startDateForFetch = Date()
    var arrForHealthdata = Array<Dictionary<String,Any>>()
    var dictForReadingRequired = Dictionary<String,Any>()
    var noOfDays:Int = 0
    override init() {
        self.arrForHealthdata.removeAll()
        super.init()
    }
    
    
    //MARK:-- Get Authorization Permission:--
    func authoriseHealthKitAccess(value:String)  {
        let healthKitTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!, HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex)!
        ]
        healthStore.requestAuthorization(toShare: nil, read: healthKitTypes ) { (bool, error) in
            if error != nil{
                print("Oops Something went wrong during getting permission...")
            }else{
                print("User has completed athorization flow...")
                DispatchQueue.main.async {
                    if value == "Steps"{
                        self.getStepsCounts()
                    }else if value == "Walking"{
                        self.getWalkingDistance()
                    }else if value == "Gender"{
                        self.genderCharachteristic()
                    }else{
                        self.getWeightValue()
                    }
                    
                }
            }
        }
    }
    /// Fetches biologicalSex of the user.
    func genderCharachteristic() {
        var gender:String = ""
        if try! healthStore.biologicalSex().biologicalSex == HKBiologicalSex.female {
            gender = "0"
            print("You are female")
        } else if try! healthStore.biologicalSex().biologicalSex == HKBiologicalSex.male {
            print("You are male")
            gender = "1"
        } else if try! healthStore.biologicalSex().biologicalSex == HKBiologicalSex.other {
            
            print("You are not categorised as male or female")
        }else{
            print("You have not selected any type")
        }
        DispatchQueue.main.async {
           var dictResult = Dictionary<String,Any>()
            dictResult["data"] = gender
            self.delegate?.saveHealthDataSuccessfully?(dict: dictResult)
        }
    }
    func getWeightValue() {
        let weight = HKSampleType.quantityType(forIdentifier: .bodyMass)!
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
               let mostRecentSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
               let sampleQuery = HKSampleQuery(sampleType: weight, predicate: predicate, limit: 1, sortDescriptors: [mostRecentSortDescriptor]) { (query, result, error) in
                   
                   DispatchQueue.main.async {
                       guard let samples = result as? [HKQuantitySample], let sample = samples.first else {
                           return
                       }
                    var dict = Dictionary<String,Any>()
                     dict["weight"] = sample.quantity.doubleValue(for: HKUnit.init(from: .kilogram))
                    self.delegate?.saveHealthDataSuccessfully?(dict: dict)
                   }
               }
               healthStore.execute(sampleQuery)
    }
    //MARK:-- STEPS COUNT
    func getStepsCounts() {
         self.arrForHealthdata.removeAll()
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -3, to: endDate)!
        if let intValue = dictForReadingRequired["noOfDays"] as? Int{
            noOfDays = intValue
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions.strictEndDate)
        
        let query = HKSampleQuery(sampleType: stepsQuantityType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
            // var i:Int = 0
            for item  in results! {
                if let value :HKQuantitySample = item as? HKQuantitySample{
                    
                    var dict = Dictionary<String,Any>()
                    dict["sourceName"] = value.sourceRevision.source.name
                    dict["startDate"] = value.startDate
                    dict["endDate"] = value.endDate
                    dict["quantity"] = value.quantity.doubleValue(for: HKUnit.count())
                    dict["distance"] = 0.0
                    self.arrForHealthdata.append(dict)
                }
            }
            DispatchQueue.main.async {
                var dictResult = Dictionary<String,Any>()
                dictResult["data"] = self.arrForHealthdata
                self.delegate?.saveHealthDataSuccessfully?(dict: dictResult)
            }
        }
        healthStore.execute(query)
    }
    
    //MARK:--WALKING DISTANCE:--
    func getWalkingDistance() {
         self.arrForHealthdata.removeAll()
        let startDate = Calendar.current.date(byAdding: .day, value: noOfDays, to: startDateForFetch)!
        let walkingQuantityType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startDateForFetch, end: startDate, options: HKQueryOptions.strictEndDate)
        
        let query = HKSampleQuery(sampleType: walkingQuantityType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
            // var i:Int = 0
            for item  in results! {
                if let value :HKQuantitySample = item as? HKQuantitySample{
                    // if self.arrForHealthdata.count > i{
                    var dict = Dictionary<String,Any>()
                    dict["startDate"] = value.startDate
                    dict["endDate"] = value.endDate
                    dict["distance"] = value.quantity.doubleValue(for: HKUnit.mile())
                    self.arrForHealthdata.append(dict)
                    
                }
            }
            DispatchQueue.main.async {
               var dictResult = Dictionary<String,Any>()
                dictResult["data"] = self.arrForHealthdata
                self.delegate?.saveHealthDataSuccessfully?(dict: dictResult)
            }
        }
        self.healthStore.execute(query)
        
    }
    
}
