//
//  HealthStoreManager.swift
//  Mini06-watchOSApp WatchKit Extension
//
//  Created by Vitor Souza on 28/06/22.
//

import Foundation
import HealthKit

struct HealthStoreManager {
    enum Errors: LocalizedError {
        case CannotFetchData
        case NoHaveHealthStore
    }
    
    static let shared = HealthStoreManager()
    var healthStore: HKHealthStore?
    
    let sleepAnalysis = HKCategoryType(.sleepAnalysis)
    
    let stepCount = HKQuantityType(.stepCount)
    let kcalLost = HKQuantityType(.activeEnergyBurned)
    let distanceWalked = HKQuantityType(.distanceWalkingRunning)
    let bpmWalking = HKQuantityType(.walkingHeartRateAverage)
    
    private let healthKitTypesToRead: Set = [
        HKCategoryType(.sleepAnalysis),
        HKQuantityType(.stepCount),
        HKQuantityType(.activeEnergyBurned),
        HKQuantityType(.distanceWalkingRunning),
        HKQuantityType(.walkingHeartRateAverage)
    ]
    
    private init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        } else {
            healthStore = nil
        }
    }

    func autorizeHealthKit(completion: @escaping () -> Void) {
        Task {
            let _ = await requestAuthorization(forRead: healthKitTypesToRead, forShare: [])
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    private func requestAuthorization(forRead: Set<HKObjectType>, forShare: Set<HKSampleType>) async -> Bool {
        return await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
            guard let healthStore = healthStore else {
                continuation.resume(returning: false)
                return
            }

            healthStore.requestAuthorization(
                toShare: forShare, read: forRead,
                completion: { (success, error) in
                    if success {
                        continuation.resume(returning: true)
                    } else {
                        continuation.resume(returning: false)
                    }
                }
            )
        }
    }
    
    func getSleepTime() async throws -> Double {
        if await requestAuthorization(forRead: [sleepAnalysis], forShare: []) {
            let descriptors = [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)]
            return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Double, Error>) in
                guard let healthStore = healthStore else {
                    continuation.resume(throwing: HealthStoreManager.Errors.NoHaveHealthStore)
                    return
                }

                let query = HKSampleQuery(
                    sampleType: HKCategoryType(.sleepAnalysis),
                    predicate: nil, limit: 5,
                    sortDescriptors: descriptors,
                    resultsHandler: { query, samples, error in
                        guard error == nil else {
                            debugPrint("[Error - Fetch Sleep Data]: \(error?.localizedDescription ?? "NO CAUSE")")
                            continuation.resume(throwing: HealthStoreManager.Errors.CannotFetchData)
                            return
                        }
                        
                        if let samples = samples as? [HKCategorySample] {
                            var amount: Double = 0.0
                            for sample in samples {
                                amount += Double(sample.endDate.timeIntervalSince(sample.startDate))
                            }
                            let average = amount / 5.0
                            continuation.resume(returning: average / 3_600.00)
                        } else {
                            continuation.resume(throwing: HealthStoreManager.Errors.CannotFetchData)
                        }
                    }
                )
                
                healthStore.execute(query)
            }
        }
        throw HealthStoreManager.Errors.CannotFetchData
    }
    
    func getStepCount() async throws -> Int {
        if await requestAuthorization(forRead: [stepCount], forShare: []) {
            return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Int, Error>) in
                guard let healthStore = healthStore else {
                    continuation.resume(throwing: HealthStoreManager.Errors.NoHaveHealthStore)
                    return
                }
                let now = Date()
                    let startOfDay = Calendar.current.startOfDay(for: now)
                    let predicate = HKQuery.predicateForSamples(
                        withStart: startOfDay,
                        end: now,
                        options: .strictStartDate
                    )
                    
                    let query = HKStatisticsQuery(
                        quantityType: stepCount,
                        quantitySamplePredicate: predicate,
                        options: .cumulativeSum
                    ) { _, result, error in
                        guard let result = result, let sum = result.sumQuantity() else {
                            debugPrint("[Error - Fetch Step Data]: \(error?.localizedDescription ?? "NO CAUSE")")
                            continuation.resume(throwing: HealthStoreManager.Errors.CannotFetchData)
                            return
                        }
                        continuation.resume(returning: Int(sum.doubleValue(for: HKUnit.count())))
                    }
                healthStore.execute(query)
            }
        }
        throw HealthStoreManager.Errors.CannotFetchData
    }
    
    
    func getKcalLost() async throws -> Int {
        if await requestAuthorization(forRead: [kcalLost], forShare: []) {
            return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Int, Error>) in
                guard let healthStore = healthStore else {
                    continuation.resume(throwing: HealthStoreManager.Errors.NoHaveHealthStore)
                    return
                }
                let now = Date()
                    let startOfDay = Calendar.current.startOfDay(for: now)
                    let predicate = HKQuery.predicateForSamples(
                        withStart: startOfDay,
                        end: now,
                        options: .strictStartDate
                    )
                    
                    let query = HKStatisticsQuery(
                        quantityType: kcalLost,
                        quantitySamplePredicate: predicate,
                        options: .cumulativeSum
                    ) { _, result, error in
                        guard let result = result, let sum = result.sumQuantity() else {
                            debugPrint("[Error - Fetch Step Data]: \(error?.localizedDescription ?? "NO CAUSE")")
                            continuation.resume(throwing: HealthStoreManager.Errors.CannotFetchData)
                            return
                        }
                        continuation.resume(returning: Int(sum.doubleValue(for: HKUnit.kilocalorie())))
                    }
                healthStore.execute(query)
            }
        }
        throw HealthStoreManager.Errors.CannotFetchData
    }
    
    
    func getDistanceWalked() async throws -> Double {
        if await requestAuthorization(forRead: [distanceWalked], forShare: []) {
            return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Double, Error>) in
                guard let healthStore = healthStore else {
                    continuation.resume(throwing: HealthStoreManager.Errors.NoHaveHealthStore)
                    return
                }
                let now = Date()
                    let startOfDay = Calendar.current.startOfDay(for: now)
                    let predicate = HKQuery.predicateForSamples(
                        withStart: startOfDay,
                        end: now,
                        options: .strictStartDate
                    )
                    
                    let query = HKStatisticsQuery(
                        quantityType: distanceWalked,
                        quantitySamplePredicate: predicate,
                        options: .cumulativeSum
                    ) { _, result, error in
                        guard let result = result, let sum = result.sumQuantity() else {
                            debugPrint("[Error - Fetch Step Data]: \(error?.localizedDescription ?? "NO CAUSE")")
                            continuation.resume(throwing: HealthStoreManager.Errors.CannotFetchData)
                            return
                        }
                        continuation.resume(returning: Double(sum.doubleValue(for: HKUnit.meterUnit(with: .kilo))))
                    }
                healthStore.execute(query)
            }
        }
        throw HealthStoreManager.Errors.CannotFetchData
    }
    
    func getBpmWalking() async throws -> Int {
        if await requestAuthorization(forRead: [bpmWalking], forShare: []) {
            return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Int, Error>) in
                guard let healthStore = healthStore else {
                    continuation.resume(throwing: HealthStoreManager.Errors.NoHaveHealthStore)
                    return
                }
                let now = Date()
                    let startOfDay = Calendar.current.startOfDay(for: now)
                    let predicate = HKQuery.predicateForSamples(
                        withStart: startOfDay,
                        end: now,
                        options: .strictStartDate
                    )
                    
                    let query = HKStatisticsQuery(
                        quantityType: bpmWalking,
                        quantitySamplePredicate: predicate,
                        options: .mostRecent
                    ) { _, result, error in
                        guard let result = result, let sum = result.mostRecentQuantity() else {
                            debugPrint("[Error - Fetch Step Data]: \(error?.localizedDescription ?? "NO CAUSE")")
                            continuation.resume(throwing: HealthStoreManager.Errors.CannotFetchData)
                            return
                        }
                        continuation.resume(returning: Int(sum.doubleValue(for: HKUnit(from: "count/min"))))
                    }
                healthStore.execute(query)
            }
        }
        throw HealthStoreManager.Errors.CannotFetchData
    }
}
