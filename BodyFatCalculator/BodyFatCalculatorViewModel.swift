//
//  BodyFatCalculatorViewModel.swift
//  BodyFatCalculator
//
//  Created by Oncu Can on 4.07.2025.
//

import Foundation
import SwiftUI // For Color type if needed, and ObservableObject

class BodyFatCalculatorViewModel: ObservableObject {
    // MARK: - Published State Variables (Accessible from View)
    @Published var weight: String = ""
    @Published var height: String = ""
    @Published var waist: String = ""
    @Published var neck: String = ""
    @Published var hip: String = "" // For females
    @Published var age: String = ""
    @Published var selectedGender: Gender = .male
    @Published var bodyFatPercentage: String = "0.0"
    
    @Published var calculationStatusMessage: String = "Enter your measurements to get started!"
    @Published var calculationStatusColor: Color = .secondary

    @Published var activeAlert: InputError? // For presenting validation errors

    @Published var errorFields: Set<String> = [] // For highlighting erroneous text fields

    // MARK: - Enums (Moved here or duplicated if needed in View)
    enum Gender: String, CaseIterable, Identifiable {
        case male = "Male"
        case female = "Female"
        var id: String { self.rawValue }
    }
    
    // MARK: - Private Helper Instances
    private let validator = InputValidator() // InputValidator remains separate

    // MARK: - Public Functions (Called from View)

    func calculateBodyFat() {
        // Clear previous states
        clearErrorHighlights()
        resetCalculationDisplay()

        let validationResult = validator.validateInputs(
            weight: weight,
            height: height,
            waist: waist,
            neck: neck,
            hip: hip,
            age: age,
            gender: selectedGender
        )

        switch validationResult {
        case .success(let inputs):
            let heightInInches = inputs.height * AppConstants.cmToInches
            let waistInInches = inputs.waist * AppConstants.cmToInches
            let neckInInches = inputs.neck * AppConstants.cmToInches

            var estimatedBF: Double = 0.0

            switch selectedGender {
            case .male:
                let logArgument = waistInInches - neckInInches
                guard logArgument > AppConstants.logArgumentThreshold else {
                    activeAlert = .maleCircumferenceIssue
                    updateCalculationStatus(message: "Check waist/neck input.", color: .red)
                    return
                }

                let term1 = AppConstants.maleFormulaTerm1
                let term2 = AppConstants.maleFormulaTerm2Factor * log10(logArgument)
                let term3 = AppConstants.maleFormulaTerm3Factor * log10(heightInInches)

                let denominator = (term1 - term2 + term3)
                guard !denominator.isNaN && denominator != 0 else {
                    activeAlert = .calculationDivisionByZero
                    updateCalculationStatus(message: "Calculation error. Values might be unrealistic or lead to NaN.", color: .red)
                    return
                }
                estimatedBF = AppConstants.maleFormulaNumerator / denominator - AppConstants.maleFormulaSubtract

            case .female:
                guard let actualHipValue = inputs.hip else {
                    activeAlert = .invalidHip
                    updateCalculationStatus(message: "Hip measurement is unexpectedly missing.", color: .red)
                    return
                }
                let hipInInches = actualHipValue * AppConstants.cmToInches

                let logArgument = waistInInches + hipInInches - neckInInches
                guard logArgument > AppConstants.logArgumentThreshold else {
                    activeAlert = .femaleCircumferenceIssue
                    updateCalculationStatus(message: "Check waist/hip/neck input.", color: .red)
                    return
                }

                let term1 = AppConstants.femaleFormulaTerm1
                let term2 = AppConstants.femaleFormulaTerm2Factor * log10(logArgument)
                let term3 = AppConstants.femaleFormulaTerm3Factor * log10(heightInInches)

                let denominator = (term1 - term2 + term3)
                guard !denominator.isNaN && denominator != 0 else {
                    activeAlert = .calculationDivisionByZero
                    updateCalculationStatus(message: "Calculation error. Values might be unrealistic or lead to NaN.", color: .red)
                    return
                }
                estimatedBF = AppConstants.femaleFormulaNumerator / denominator - AppConstants.femaleFormulaSubtract
            }

            bodyFatPercentage = String(format: "%.1f", max(0.0, min(100.0, estimatedBF)))
            updateCalculationStatus(message: "Your estimated body fat percentage.", color: .secondary)

        case .failure(let error):
            activeAlert = error
            updateCalculationStatus(message: error.localizedDescription, color: .red)
            highlightErrorField(error: error)
        }
    }

    func resetAllFields() {
        weight = ""
        height = ""
        waist = ""
        neck = ""
        hip = ""
        age = ""
        selectedGender = .male // Reset to default gender
        resetCalculationDisplay()
        clearErrorHighlights()
    }
    
    // MARK: - Private Helper Functions (Internal to ViewModel)

    private func resetCalculationDisplay() {
        bodyFatPercentage = "0.0"
        calculationStatusMessage = "Enter your measurements to get started!"
        calculationStatusColor = .secondary
    }
    
    private func updateCalculationStatus(message: String, color: Color) {
        calculationStatusMessage = message
        calculationStatusColor = color
    }

    // Function to highlight the field that caused the error
    func highlightErrorField(error: InputError) {
        clearErrorHighlights() // Clear previous highlights first
        if let fieldId = error.fieldId {
            errorFields.insert(fieldId)
        }
    }

    // Function to clear all error highlights
    func clearErrorHighlights() {
        errorFields.removeAll()
    }
}
