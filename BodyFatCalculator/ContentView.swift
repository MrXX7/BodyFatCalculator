//
//  ContentView.swift
//  BodyFatCalculator
//
//  Created by Oncu Can on 22.05.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var weight: String = "" // Weight in kg
    @State private var height: String = "" // Height in cm
    @State private var waist: String = ""  // Waist circumference in cm
    @State private var neck: String = ""   // Neck circumference in cm
    @State private var hip: String = ""    // Hip circumference in cm (for females)
    @State private var age: String = ""    // Age in years
    @State private var selectedGender: Gender = .male // Default to Male
    @State private var bodyFatPercentage: String = "0.0" // Body fat percentage

    enum Gender: String, CaseIterable, Identifiable {
        case male = "Male"
        case female = "Female"
        var id: String { self.rawValue }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Body Information")) {
                    TextField("Weight (kg)", text: $weight)
                        .keyboardType(.decimalPad)
                    TextField("Height (cm)", text: $height)
                        .keyboardType(.decimalPad)
                    TextField("Waist (cm)", text: $waist)
                        .keyboardType(.decimalPad)
                    TextField("Neck (cm)", text: $neck)
                        .keyboardType(.decimalPad)

                    if selectedGender == .female {
                        TextField("Hip (cm)", text: $hip)
                            .keyboardType(.decimalPad)
                    }

                    TextField("Age (years)", text: $age)
                        .keyboardType(.numberPad)

                    Picker("Gender", selection: $selectedGender) {
                        ForEach(Gender.allCases) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                    .pickerStyle(.segmented) // Segmented control for gender selection
                }

                Button("Calculate Body Fat") {
                    calculateBodyFat()
                }

                Section(header: Text("Body Fat Result")) {
                    Text("Estimated Body Fat: %\(bodyFatPercentage)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
            .navigationTitle("Body Fat Calculator")
        }
    }

    private func calculateBodyFat() {
        guard let weightValue = Double(weight),
              let heightValue = Double(height),
              let waistValue = Double(waist),
              let neckValue = Double(neck),
              let ageValue = Double(age) else {
            bodyFatPercentage = "Invalid Input"
            return
        }

        // Convert cm to inches for the US Navy formula
        let heightInInches = heightValue * 0.393701
        let waistInInches = waistValue * 0.393701
        let neckInInches = neckValue * 0.393701

        var estimatedBF: Double = 0.0

        switch selectedGender {
        case .male:
            // US Navy Body Fat Formula for Men
            // BF% = 495 / (1.0324 - 0.19077 * log10(waist(in) - neck(in)) + 0.15456 * log10(height(in))) - 450
            let term1 = 1.0324
            let term2 = 0.19077 * log10(waistInInches - neckInInches)
            let term3 = 0.15456 * log10(heightInInches)
            estimatedBF = 495 / (term1 - term2 + term3) - 450

        case .female:
            guard let hipValue = Double(hip) else {
                bodyFatPercentage = "Invalid Input"
                return
            }
            let hipInInches = hipValue * 0.393701

            // US Navy Body Fat Formula for Women
            // BF% = 495 / (1.29579 - 0.35004 * log10(waist(in) + hip(in) - neck(in)) + 0.22100 * log10(height(in))) - 450
            let term1 = 1.29579
            let term2 = 0.35004 * log10(waistInInches + hipInInches - neckInInches)
            let term3 = 0.22100 * log10(heightInInches)
            estimatedBF = 495 / (term1 - term2 + term3) - 450
        }

        // Ensure the percentage is between 0 and 100
        bodyFatPercentage = String(format: "%.1f", max(0, min(100, estimatedBF)))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
