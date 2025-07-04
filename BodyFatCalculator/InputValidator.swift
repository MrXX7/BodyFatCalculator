//
//  InputValidator.swift
//  BodyFatCalculator
//
//  Created by Oncu Can on 13.06.2025.
//

import Foundation
import SwiftUI

enum InputError: Error, LocalizedError, Identifiable {
    case invalidWeight
    case invalidHeight
    case invalidWaist
    case invalidNeck
    case invalidHip
    case invalidAge
    case maleCircumferenceIssue
    case femaleCircumferenceIssue
    case calculationDivisionByZero
    case genericInvalidInput

    var fieldId: String? {
        switch self {
        case .invalidWeight: return "weight"
        case .invalidHeight: return "height"
        case .invalidWaist: return "waist"
        case .invalidNeck: return "neck"
        case .invalidHip: return "hip"
        case .invalidAge: return "age"
        default: return nil
        }
    }

    var id: String { self.localizedDescription }

    var errorDescription: String? {
        switch self {
        case .invalidWeight:
            return NSLocalizedString("Please enter a valid, positive number for your Weight (kg).", comment: "Weight input error")
        case .invalidHeight:
            return NSLocalizedString("Please enter a valid, positive number for your Height (cm).", comment: "Height input error")
        case .invalidWaist:
            return NSLocalizedString("Please enter a valid, positive number for your Waist circumference (cm).", comment: "Waist input error")
        case .invalidNeck:
            return NSLocalizedString("Please enter a valid, positive number for your Neck circumference (cm).", comment: "Neck input error")
        case .invalidHip:
            return NSLocalizedString("For females, please enter a valid, positive number for your Hip circumference (cm).", comment: "Hip input error for females")
        case .invalidAge:
            return NSLocalizedString("Please enter a valid, non-negative number for your Age (years).", comment: "Age input error")
        case .maleCircumferenceIssue:
            return NSLocalizedString("For men, your waist measurement must be significantly larger than your neck measurement for an accurate calculation. Please re-check these values.", comment: "Male circumference error")
        case .femaleCircumferenceIssue:
            return NSLocalizedString("For women, the combined waist and hip measurements must be significantly larger than your neck measurement for an accurate calculation. Please re-check these values.", comment: "Female circumference error")
        case .calculationDivisionByZero:
            return NSLocalizedString("A calculation error occurred (division by zero). Please ensure your measurements are realistic and try again.", comment: "Calculation error")
        case .genericInvalidInput:
            return NSLocalizedString("Please ensure all fields are filled with valid numeric values.", comment: "Generic input error")
        }
    }
}

struct InputValidator {
    func safeDouble(from string: String, allowZero: Bool = false) -> Double? {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedString.isEmpty { return nil }
        guard let value = Double(trimmedString) else { return nil }
        if !allowZero && value <= 0 { return nil }
        if allowZero && value < 0 { return nil }
        return value
    }
    
    func validateInputs(
        weight: String,
        height: String,
        waist: String,
        neck: String,
        hip: String,
        age: String,
        gender: BodyFatCalculatorViewModel.Gender // ViewModel'daki Gender'ı kullanmak için bu enum'ı ContentView'de de tutmalıyız veya ViewModel'ın enum'unu kullanmalıyız. Şu anlık ContentView'deki referansa devam ettim.
    ) -> Result<(weight: Double, height: Double, waist: Double, neck: Double, hip: Double?, age: Double), InputError> {

        guard let weightValue = safeDouble(from: weight) else { return .failure(.invalidWeight) }
        guard let heightValue = safeDouble(from: height) else { return .failure(.invalidHeight) }
        guard let waistValue = safeDouble(from: waist) else { return .failure(.invalidWaist) }
        guard let neckValue = safeDouble(from: neck) else { return .failure(.invalidNeck) }
        guard let ageValue = safeDouble(from: age, allowZero: true) else { return .failure(.invalidAge) }

        var hipValue: Double? = nil
        if gender == .female {
            guard let femaleHipValue = safeDouble(from: hip) else { return .failure(.invalidHip) }
            hipValue = femaleHipValue
        }

        return .success((weightValue, heightValue, waistValue, neckValue, hipValue, ageValue))
    }
}
