//
//  Constants.swift
//  BodyFatCalculator
//
//  Created by Oncu Can on 13.06.2025.
//

import Foundation

struct AppConstants {
    static let cmToInches: Double = 0.393701

    static let maleFormulaNumerator: Double = 495.0
    static let maleFormulaTerm1: Double = 1.0324
    static let maleFormulaTerm2Factor: Double = 0.19077
    static let maleFormulaTerm3Factor: Double = 0.15456
    static let maleFormulaSubtract: Double = 450.0

    static let femaleFormulaNumerator: Double = 495.0
    static let femaleFormulaTerm1: Double = 1.29579
    static let femaleFormulaTerm2Factor: Double = 0.35004
    static let femaleFormulaTerm3Factor: Double = 0.22100
    static let femaleFormulaSubtract: Double = 450.0

    static let logArgumentThreshold: Double = 0.1
}
