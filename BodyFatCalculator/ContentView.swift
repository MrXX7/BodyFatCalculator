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
    @State private var showingAlert: Bool = false // State for showing an alert
    @State private var alertMessage: String = "" // Message to display in the alert

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
                Section(header: Text("Body Information")
                    .font(.headline)
                    .foregroundColor(.accentColor)
                ) {
                    Group { // Grouping TextFields for better readability
                        TextField("Weight (kg)", text: $weight)
                            .keyboardType(.decimalPad)
                            .autocorrectionDisabled()
                        TextField("Height (cm)", text: $height)
                            .keyboardType(.decimalPad)
                            .autocorrectionDisabled()
                        TextField("Waist (cm)", text: $waist)
                            .keyboardType(.decimalPad)
                            .autocorrectionDisabled()
                        TextField("Neck (cm)", text: $neck)
                            .keyboardType(.decimalPad)
                            .autocorrectionDisabled()
                    }
                    .padding(.vertical, 4) // Add slight vertical padding for each text field

                    // Hip measurement is only required for females
                    if selectedGender == .female {
                        TextField("Hip (cm)", text: $hip)
                            .keyboardType(.decimalPad)
                            .autocorrectionDisabled()
                            .padding(.vertical, 4)
                    }

                    TextField("Age (years)", text: $age)
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
                        // Reset hip measurement and body fat percentage when gender changes
                        if selectedGender == .male {
                            hip = "" // Clear hip field if switching to male
                        }
                        bodyFatPercentage = "0.0" // Reset result to 0.0
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
                .listRowBackground(Color.clear) // Remove default background for the button row
                .padding(.vertical)

                // New Reset Button here
                ResetButton(action: resetAllFields)
                    .listRowBackground(Color.clear)

                // Section to display the calculated body fat percentage
                Section(header: Text("Results")
                    .font(.headline)
                    .foregroundColor(.accentColor)
                ) {
                    HStack {
                        Spacer()
                        VStack(alignment: .center) {
                            Text("Estimated Body Fat:")
                                .font(.title3)
                                .foregroundColor(.secondary)
                            Text("\(bodyFatPercentage)%")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .foregroundColor(.green) // Highlight the result in green
                                .animation(.easeIn, value: bodyFatPercentage) // Animate the text change
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Body Fat Calculator") // Title for the navigation bar
            .navigationBarTitleDisplayMode(.inline) // Make title smaller and inline
            .alert(isPresented: $showingAlert) { // Alert for error messages
                Alert(title: Text("Input Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .onTapGesture {
                // Dismiss keyboard when tapping anywhere in the form
                hideKeyboard()
            }
        }
    }

    // MARK: - Private Functions

    /// Helper function to safely convert a string to a Double.
    /// Returns nil if conversion fails or if the resulting value is not positive (unless allowZero is true for age).
    private func safeDouble(from string: String, allowZero: Bool = false) -> Double? {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedString.isEmpty { return nil } // Treat empty as invalid
        guard let value = Double(trimmedString) else { return nil }
        if !allowZero && value <= 0 { return nil } // Ensure positive for measurements
        if allowZero && value < 0 { return nil } // Ensure non-negative for age
        return value
    }

    /// Function to calculate body fat percentage based on US Navy formula
    private func calculateBodyFat() {
        // Dismiss keyboard before calculation to ensure all inputs are committed
        hideKeyboard()

        // Reset alert state and message
        alertMessage = ""
        showingAlert = false
        bodyFatPercentage = "0.0" // Reset result immediately on calculation attempt

        // --- DEBUG PRINT: Raw input strings ---
        print("DEBUG: Raw Inputs - Weight: '\(weight)', Height: '\(height)', Waist: '\(waist)', Neck: '\(neck)', Hip: '\(hip)', Age: '\(age)'")

        // Safely unwrap and convert input strings to Double using the new helper
        guard let weightValue = safeDouble(from: weight) else {
            alertMessage = "Please enter a valid, positive number for Weight."
            showingAlert = true
            return
        }
        guard let heightValue = safeDouble(from: height) else {
            alertMessage = "Please enter a valid, positive number for Height."
            showingAlert = true
            return
        }
        guard let waistValue = safeDouble(from: waist) else {
            alertMessage = "Please enter a valid, positive number for Waist."
            showingAlert = true
            return
        }
        guard let neckValue = safeDouble(from: neck) else {
            alertMessage = "Please enter a valid, positive number for Neck."
            showingAlert = true
            return
        }
        guard let ageValue = safeDouble(from: age, allowZero: true) else {
            alertMessage = "Please enter a valid, non-negative number for Age."
            showingAlert = true
            return
        }
        // --- DEBUG PRINT: Converted Double values ---
        print("DEBUG: Converted Values - Weight: \(weightValue), Height: \(heightValue), Waist: \(waistValue), Neck: \(neckValue), Age: \(ageValue)")


        // Convert cm measurements to inches for the US Navy formula
        let heightInInches = heightValue * 0.393701
        let waistInInches = waistValue * 0.393701
        let neckInInches = neckValue * 0.393701

        // --- DEBUG PRINT: Converted to Inches ---
        print("DEBUG: Inches Values - Height: \(heightInInches), Waist: \(waistInInches), Neck: \(neckInInches)")

        var estimatedBF: Double = 0.0

        // Apply the specific formula based on selected gender
        switch selectedGender {
        case .male:
            let logArgument = waistInInches - neckInInches
            // --- DEBUG PRINT: Male logArgument ---
            print("DEBUG: Male logArgument (waist - neck): \(logArgument)")

            // Ensure the argument for log10 is strictly positive and sufficiently large
            guard logArgument > 0.1 else { // Increased threshold slightly for more robust calculation
                alertMessage = "For men, your waist measurement must be significantly larger than your neck measurement to calculate body fat. Please re-check inputs."
                showingAlert = true
                return
            }

            // US Navy Body Fat Formula for Men:
            // BF% = 495 / (1.0324 - 0.19077 * log10(waist(in) - neck(in)) + 0.15456 * log10(height(in))) - 450
            let term1 = 1.0324
            let term2 = 0.19077 * log10(logArgument)
            let term3 = 0.15456 * log10(heightInInches)

            let denominator = (term1 - term2 + term3)
            // --- DEBUG PRINT: Male Denominator ---
            print("DEBUG: Male Denominator: \(denominator)")

            guard denominator != 0 else {
                alertMessage = "A calculation error occurred (division by zero). Please verify your measurements are realistic."
                showingAlert = true
                return
            }
            estimatedBF = 495 / denominator - 450

        case .female:
            // For females, hip circumference is also required
            guard let hipValue = safeDouble(from: hip) else {
                alertMessage = "Please enter a valid, positive hip circumference for females."
                showingAlert = true
                return
            }
            let hipInInches = hipValue * 0.393701
            // --- DEBUG PRINT: Female Hip in Inches ---
            print("DEBUG: Female Hip in Inches: \(hipInInches)")

            let logArgument = waistInInches + hipInInches - neckInInches
            // --- DEBUG PRINT: Female logArgument (waist + hip - neck): \(logArgument) ---
            print("DEBUG: Female logArgument: \(logArgument)")

            // Ensure the argument for log10 is strictly positive and sufficiently large
            guard logArgument > 0.1 else { // Increased threshold slightly for more robust calculation
                alertMessage = "For women, the combined waist and hip measurements must be significantly larger than your neck measurement. Please re-check inputs."
                showingAlert = true
                return
            }

            // US Navy Body Fat Formula for Women:
            // BF% = 495 / (1.29579 - 0.35004 * log10(waist(in) + hip(in) - neck(in)) + 0.22100 * log10(height(in))) - 450
            let term1 = 1.29579
            let term2 = 0.35004 * log10(logArgument)
            let term3 = 0.22100 * log10(heightInInches)

            let denominator = (term1 - term2 + term3)
            // --- DEBUG PRINT: Female Denominator ---
            print("DEBUG: Female Denominator: \(denominator)")

            guard denominator != 0 else {
                alertMessage = "A calculation error occurred (division by zero). Please verify your measurements are realistic."
                showingAlert = true
                return
            }
            estimatedBF = 495 / denominator - 450
        }

        // Format the result to one decimal place and ensure it's within 0-100%
        bodyFatPercentage = String(format: "%.1f", max(0.0, min(100.0, estimatedBF)))
        // --- DEBUG PRINT: Final Body Fat Percentage ---
        print("DEBUG: Final Estimated Body Fat: \(bodyFatPercentage)%")
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
        bodyFatPercentage = "0.0" // Reset result
        alertMessage = "" // Clear any previous alert message
        showingAlert = false // Hide any active alert
        hideKeyboard() // Dismiss keyboard
        print("DEBUG: All fields reset.")
    }
}

// MARK: - Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
