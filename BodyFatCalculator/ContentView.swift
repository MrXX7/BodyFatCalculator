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
    @State private var bodyFatPercentage: String = "0.0" // Body fat percentage

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
                }

                Button("Calculate") {
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
        // Ensure all inputs can be converted to Double
        guard let weightValue = Double(weight),
              let heightValue = Double(height),
              let waistValue = Double(waist) else {
            // Handle invalid input (e.g., non-numeric)
            bodyFatPercentage = "Invalid Input"
            return
        }

        // Calculate Body Mass Index (BMI)
        // BMI = weight (kg) / (height (m))^2
        let heightInMeters = heightValue / 100 // Convert cm to meters
        let bmi = weightValue / (heightInMeters * heightInMeters)

        // Estimate Body Fat Percentage using a simplified formula based on BMI.
        // This formula is often used for a general estimation and typically
        // includes age and gender. For simplicity, we'll assume a male of age 30.
        // Formula: Body Fat % = (1.20 * BMI) + (0.23 * Age) - (10.8 * Gender) - 5.4
        // Gender: Male = 1, Female = 0
        let age: Double = 30 // Assumed age for calculation
        let genderFactor: Double = 1 // 1 for Male, 0 for Female (assuming Male for this example)

        let estimatedBF = (1.20 * bmi) + (0.23 * age) - (10.8 * genderFactor) - 5.4

        // Format the result to one decimal place and ensure it's within 0-100%
        bodyFatPercentage = String(format: "%.1f", max(0, min(100, estimatedBF)))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
