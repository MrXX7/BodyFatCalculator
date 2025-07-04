//
//  BodyInfoSection.swift
//  BodyFatCalculator
//
//  Created by Oncu Can on 4.07.2025.
//

import SwiftUI

struct BodyInfoSection: View {
    @ObservedObject var viewModel: BodyFatCalculatorViewModel // ViewModel'ı dinleyeceğiz
    @FocusState var focusedField: ContentView.Field? // ContentView'den gelen FocusState

    var body: some View {
        Section(header: Text("BODY INFORMATION")
            .font(.headline)
            .foregroundColor(Color("AccentBlue"))
        ) {
            Group {
                TextField("Weight (kg)", text: $viewModel.weight, prompt: Text("e.g., 75.0 kg"))
                    .keyboardType(.decimalPad)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .weight)
                    .modifier(ErrorBorder(isError: viewModel.errorFields.contains("weight")))
                
                TextField("Height (cm)", text: $viewModel.height, prompt: Text("e.g., 170.0 cm"))
                    .keyboardType(.decimalPad)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .height)
                    .modifier(ErrorBorder(isError: viewModel.errorFields.contains("height")))
                
                TextField("Waist (cm)", text: $viewModel.waist, prompt: Text("e.g., 80.0 cm"))
                    .keyboardType(.decimalPad)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .waist)
                    .modifier(ErrorBorder(isError: viewModel.errorFields.contains("waist")))
                
                TextField("Neck (cm)", text: $viewModel.neck, prompt: Text("e.g., 35.0 cm"))
                    .keyboardType(.decimalPad)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .neck)
                    .modifier(ErrorBorder(isError: viewModel.errorFields.contains("neck")))
            }
            .padding(.vertical, 4)

            if viewModel.selectedGender == .female {
                TextField("Hip (cm)", text: $viewModel.hip, prompt: Text("e.g., 90.0 cm"))
                    .keyboardType(.decimalPad)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .hip)
                    .modifier(ErrorBorder(isError: viewModel.errorFields.contains("hip")))
                    .padding(.vertical, 4)
            }

            TextField("Age (years)", text: $viewModel.age, prompt: Text("e.g., 30 years"))
                .keyboardType(.numberPad)
                .autocorrectionDisabled()
                .focused($focusedField, equals: .age)
                .modifier(ErrorBorder(isError: viewModel.errorFields.contains("age")))
                .padding(.vertical, 4)

            Picker("Gender", selection: $viewModel.selectedGender) {
                ForEach(BodyFatCalculatorViewModel.Gender.allCases) { gender in
                    Text(gender.rawValue).tag(gender)
                }
            }
            .pickerStyle(.segmented)
            .padding(.vertical, 4)
            .onChange(of: viewModel.selectedGender) { _ in
                if viewModel.selectedGender == .male {
                    viewModel.hip = "" // Clear hip when switching to male
                }
                viewModel.resetAllFields() // ViewModel'deki reset fonksiyonunu kullan
            }
        }
    }
}

