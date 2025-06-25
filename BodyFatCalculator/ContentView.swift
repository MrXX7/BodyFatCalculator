//
//  ContentView.swift
//  BodyFatCalculator
//
//  Created by Oncu Can on 22.05.2025.
//

import SwiftUI

struct ContentView: View {
    // MARK: - State Variables
    @State private var weight: String = ""      // Weight in kg
    @State private var height: String = ""      // Height in cm
    @State private var waist: String = ""       // Waist circumference in cm
    @State private var neck: String = ""        // Neck circumference in cm
    @State private var hip: String = ""         // Hip circumference in cm (for females)
    @State private var age: String = ""         // Age in years
    @State private var selectedGender: Gender = .male // Default to Male
    @State private var bodyFatPercentage: String = "0.0" // Body fat percentage
    
    // State for explicitly showing error message below result
    @State private var calculationStatusMessage: String = "Enter your measurements to get started!"
    @State private var calculationStatusColor: Color = .secondary

    // Using `InputError?` to conform to `Identifiable` for `.alert(item:)`
    @State private var activeAlert: InputError?

    // MARK: - Enums
    enum Gender: String, CaseIterable, Identifiable {
        case male = "Male"
        case female = "Female"
        var id: String { self.rawValue }
    }

    // MARK: - Body
    var body: some View {
        NavigationView {
            Form {
                // Section for collecting body measurements
                Section(header: Text("BODY INFORMATION")
                    .font(.headline)
                    .foregroundColor(.accentColor)
                ) {
                    Group {
                        TextField("Weight (kg)", text: $weight, prompt: Text("e.g., 75.0"))
                            .keyboardType(.decimalPad)
                            .autocorrectionDisabled()
                        TextField("Height (cm)", text: $height, prompt: Text("e.g., 170.0"))
                            .keyboardType(.decimalPad)
                            .autocorrectionDisabled()
                        TextField("Waist (cm)", text: $waist, prompt: Text("e.g., 80.0"))
                            .keyboardType(.decimalPad)
                            .autocorrectionDisabled()
                        TextField("Neck (cm)", text: $neck, prompt: Text("e.g., 35.0"))
                            .keyboardType(.decimalPad)
                            .autocorrectionDisabled()
                    }
                    .padding(.vertical, 4)

                    // Hip measurement is only required for females
                    if selectedGender == .female {
                        TextField("Hip (cm)", text: $hip, prompt: Text("e.g., 90.0 (for females)"))
                            .keyboardType(.decimalPad)
                            .autocorrectionDisabled()
                            .padding(.vertical, 4)
                    }

                    TextField("Age (years)", text: $age, prompt: Text("e.g., 30"))
                        .keyboardType(.numberPad)
                        .autocorrectionDisabled()
                        .padding(.vertical, 4)

                    // Gender selection with a segmented picker
                    Picker("Gender", selection: $selectedGender) {
                        ForEach(Gender.allCases) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 4)
                    .onChange(of: selectedGender) { _ in
                        resetCalculationDisplay() // Reset result and message on gender change
                    }
                }

                // Button to trigger the body fat calculation
                Button(action: calculateBodyFat) {
                    Label("Calculate Body Fat", systemImage: "arrow.right.circle.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .listRowBackground(Color.clear)
                .padding(.vertical)

                // Reset Button
                ResetButton(action: resetAllFields)
                    .listRowBackground(Color.clear)

                // Section to display the calculated body fat percentage and status message
                Section(header: Text("RESULTS")
                    .font(.headline)
                    .foregroundColor(.accentColor)
                ) {
                    VStack(alignment: .center, spacing: 10) {
                        Text("Estimated Body Fat:")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        Text("\(bodyFatPercentage)%")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(.green)
                            .animation(.easeIn, value: bodyFatPercentage)

                        Text(calculationStatusMessage)
                            .font(.caption)
                            .foregroundColor(calculationStatusColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity) // Center the VStack content
                    .padding(.vertical)
                }
            }
            .navigationTitle("Body Fat Calculator")
            .navigationBarTitleDisplayMode(.inline)
            // Use .alert(item:) with Identifiable Error
            .alert(item: $activeAlert) { error in
                Alert(title: Text("Input Error"), message: Text(error.localizedDescription), dismissButton: .default(Text("OK")))
            }
//            .onTapGesture {
//                hideKeyboard()
//            }
        }
    }

    // MARK: - Private Functions

    /// Function to calculate body fat percentage based on US Navy formula
    private func calculateBodyFat() {
        hideKeyboard()
        resetCalculationDisplay() // Reset status before new calculation attempt

        let validator = InputValidator()

        // Validate all inputs first
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
            // Inputs are valid, proceed with calculation
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
                guard denominator != 0 else {
                    activeAlert = .calculationDivisionByZero
                    updateCalculationStatus(message: "Calculation error. Values might be unrealistic.", color: .red)
                    return
                }
                estimatedBF = AppConstants.maleFormulaNumerator / denominator - AppConstants.maleFormulaSubtract

            case .female:
                // FIX: inputs.hip is a Double?, we need to safely unwrap it here for multiplication.
                guard let actualHipValue = inputs.hip else {
                    // This scenario should ideally not be reached if InputValidator works correctly for females,
                    // but it acts as a safeguard.
                    activeAlert = .invalidHip
                    updateCalculationStatus(message: "Hip measurement is unexpectedly missing.", color: .red)
                    return
                }
                let hipInInches = actualHipValue * AppConstants.cmToInches // Corrected line

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
                guard denominator != 0 else {
                    activeAlert = .calculationDivisionByZero
                    updateCalculationStatus(message: "Calculation error. Values might be unrealistic.", color: .red)
                    return
                }
                estimatedBF = AppConstants.femaleFormulaNumerator / denominator - AppConstants.femaleFormulaSubtract
            }

            // Format the result and ensure it's within 0-100%
            bodyFatPercentage = String(format: "%.1f", max(0.0, min(100.0, estimatedBF)))
            updateCalculationStatus(message: "Your estimated body fat percentage.", color: .secondary)

        case .failure(let error):
            // Validation failed, set the alert and update status message
            activeAlert = error
            updateCalculationStatus(message: error.localizedDescription, color: .red)
        }
    }

    /// Helper function to dismiss the keyboard
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    /// Function to reset all input fields and results
    private func resetAllFields() {
        weight = ""
        height = ""
        waist = ""
        neck = ""
        hip = ""
        age = ""
        selectedGender = .male // Reset to default gender
        resetCalculationDisplay() // Reset result and status message
        hideKeyboard()
    }
    
    /// Resets the body fat percentage and status message display.
    private func resetCalculationDisplay() {
        bodyFatPercentage = "0.0"
        calculationStatusMessage = "Enter your measurements to get started!"
        calculationStatusColor = .secondary
    }
    
    /// Updates the status message below the body fat percentage.
    private func updateCalculationStatus(message: String, color: Color) {
        calculationStatusMessage = message
        calculationStatusColor = color
    }
}

// MARK: - Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
