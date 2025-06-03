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
                        // Reset hip measurement when gender changes to male
                        if selectedGender == .male {
                            hip = ""
                        }
                        // Reset body fat percentage when gender changes
                        bodyFatPercentage = "0.0"
                    }
                }

                // Button to trigger the body fat calculation
                Button(action: calculateBodyFat) {
                    Label("Calculate Body Fat", systemImage: "arrow.triangle.right.circle.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .listRowBackground(Color.clear) // Remove default background for the button row
                .padding(.vertical)

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
                // Dismiss keyboard when tapping outside of text fields
                hideKeyboard()
            }
        }
    }

    // MARK: - Private Functions

    /// Function to calculate body fat percentage based on US Navy formula
    private func calculateBodyFat() {
        // Dismiss keyboard before calculation
        hideKeyboard()

        // Safely unwrap and convert input strings to Double, trimming whitespace
        guard let weightValue = Double(weight.trimmingCharacters(in: .whitespacesAndNewlines)), weightValue > 0,
              let heightValue = Double(height.trimmingCharacters(in: .whitespacesAndNewlines)), heightValue > 0,
              let waistValue = Double(waist.trimmingCharacters(in: .whitespacesAndNewlines)), waistValue > 0,
              let neckValue = Double(neck.trimmingCharacters(in: .whitespacesAndNewlines)), neckValue > 0,
              let ageValue = Double(age.trimmingCharacters(in: .whitespacesAndNewlines)), ageValue >= 0 else {
            alertMessage = "Please ensure all fields are filled with valid, positive numeric values. Age cannot be negative."
            showingAlert = true
            bodyFatPercentage = "0.0" // Reset to default
            return
        }

        // Convert cm measurements to inches for the US Navy formula
        let heightInInches = heightValue * 0.393701
        let waistInInches = waistValue * 0.393701
        let neckInInches = neckValue * 0.393701

        var estimatedBF: Double = 0.0

        // Apply the specific formula based on selected gender
        switch selectedGender {
        case .male:
            // Ensure (waist - neck) is positive to avoid log10 errors and practical limits
            guard (waistInInches - neckInInches) > 0.01 else { // Using 0.01 for a small positive threshold
                alertMessage = "For men, waist circumference must be noticeably greater than neck circumference for accurate calculation."
                showingAlert = true
                bodyFatPercentage = "0.0"
                return
            }
            // US Navy Body Fat Formula for Men:
            // BF% = 495 / (1.0324 - 0.19077 * log10(waist(in) - neck(in)) + 0.15456 * log10(height(in))) - 450
            let term1 = 1.0324
            let term2 = 0.19077 * log10(waistInInches - neckInInches)
            let term3 = 0.15456 * log10(heightInInches)

            // Prevent division by zero or very small numbers close to zero
            let denominator = (term1 - term2 + term3)
            guard denominator != 0 else {
                alertMessage = "Calculation error: Division by zero. Please check your inputs."
                showingAlert = true
                bodyFatPercentage = "0.0"
                return
            }
            estimatedBF = 495 / denominator - 450

        case .female:
            // For females, hip circumference is also required
            guard let hipValue = Double(hip.trimmingCharacters(in: .whitespacesAndNewlines)), hipValue > 0 else {
                alertMessage = "Please enter a valid, positive hip circumference for females."
                showingAlert = true
                bodyFatPercentage = "0.0"
                return
            }
            let hipInInches = hipValue * 0.393701

            // Ensure (waist + hip - neck) is positive to avoid log10 errors and practical limits
            guard (waistInInches + hipInInches - neckInInches) > 0.01 else { // Using 0.01 for a small positive threshold
                alertMessage = "For women, the sum of waist and hip minus neck circumference must be positive and significant for accurate calculation."
                showingAlert = true
                bodyFatPercentage = "0.0"
                return
            }
            // US Navy Body Fat Formula for Women:
            // BF% = 495 / (1.29579 - 0.35004 * log10(waist(in) + hip(in) - neck(in)) + 0.22100 * log10(height(in))) - 450
            let term1 = 1.29579
            let term2 = 0.35004 * log10(waistInInches + hipInInches - neckInInches)
            let term3 = 0.22100 * log10(heightInInches)

            // Prevent division by zero or very small numbers close to zero
            let denominator = (term1 - term2 + term3)
            guard denominator != 0 else {
                alertMessage = "Calculation error: Division by zero. Please check your inputs."
                showingAlert = true
                bodyFatPercentage = "0.0"
                return
            }
            estimatedBF = 495 / denominator - 450
        }

        // Format the result to one decimal place and ensure it's within 0-100%
        // A very low or negative body fat percentage is physiologically impossible.
        // A very high percentage might indicate extreme obesity but values should be capped for presentation.
        bodyFatPercentage = String(format: "%.1f", max(0, min(100, estimatedBF)))
    }

    /// Helper function to dismiss the keyboard
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
