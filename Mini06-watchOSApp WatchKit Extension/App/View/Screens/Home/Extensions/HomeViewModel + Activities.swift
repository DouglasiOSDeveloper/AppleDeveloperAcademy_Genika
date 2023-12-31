//
//  HomeViewModel + Activities.swift
//  Mini06-watchOSApp WatchKit Extension
//
//  Created by Lucas Alexandre Amorim Leoncio on 29/06/22.
//

import SwiftUI

extension HomeViewModel{
    internal func updateExerciceData(exerciceArray: [Exercice]) {
        guard !exerciceArray.isEmpty else {
            activityQuantityValue = .none
            activityQualityValue = 0
            activityFocusDataModel.qualityLabel = ""
            activityFocusDataModel.quantityLabel = ""
            return
        }
        
        //quantity
        var amount: Double = 0.0
        exerciceArray.forEach { exercice in
            amount += Double(exercice.bpmWalking)
        }
        
        let average = amount / Double(exerciceArray.count)
        switch average {
        case let bpm where bpm < 40:
            activityQuantityValue = .lowest
        case let bpm where bpm < 80:
            activityQuantityValue = .low
        case let bpm where bpm < 120:
            activityQuantityValue = .medium
        case let bpm where bpm < 160:
            activityQuantityValue = .high
        default:
            activityQuantityValue = .highest
        }
        
        activityFocusDataModel.quantityLabel = "\(Int(average)) BPM"

        
        //quality
        var qualityAmount: Double = 0
        exerciceArray.forEach { exercice in
            var quality: Double = 0
            
            switch exercice.countSteps{
            case let steps where steps < 2000:
                break
            case let steps where steps < 5000:
                quality += 1
            case let steps where steps < 7000:
                quality += 2
            case let steps where steps < 10000:
                quality += 3
            default:
                quality += 4
            }
            
            switch exercice.kcalLost{
            case let kcal where kcal < 100:
                break
            case let kcal where kcal < 200:
                quality += 1
            case let kcal where kcal < 300:
                quality += 2
            case let kcal where kcal < 500:
                quality += 3
            default:
                quality += 4
            }
            
            switch exercice.distanceWalked{
            case let distanceWalked where distanceWalked < 1:
                break
            case let distanceWalked where distanceWalked < 3:
                quality += 1
            case let distanceWalked where distanceWalked < 6:
                quality += 2
            case let distanceWalked where distanceWalked < 8:
                quality += 3
            default:
                quality += 4
            }
            qualityAmount += quality
        }
        
        let qualityAverage = qualityAmount / Double(exerciceArray.count)
        activityQualityValue = (100 * qualityAverage) / 12
        
        switch activityQualityValue{
        case let quality where quality <= 20:
            activityFocusDataModel.qualityLabel = "Muito Leve"
        case let quality where quality <= 40:
            activityFocusDataModel.qualityLabel = "Leve"
        case let quality where quality <= 60:
            activityFocusDataModel.qualityLabel = "Regular"
        case let quality where quality <= 80:
            activityFocusDataModel.qualityLabel = "Ótimo"
        default:
            activityFocusDataModel.qualityLabel = "Excelente"
        }
    }
}
