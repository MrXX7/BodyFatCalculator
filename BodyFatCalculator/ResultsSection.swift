//
//  ResultsSection.swift
//  BodyFatCalculator
//
//  Created by Oncu Can on 4.07.2025.
//

import SwiftUI

struct ResultsSection: View {
    @ObservedObject var viewModel: BodyFatCalculatorViewModel // ViewModel'ı dinleyeceğiz

    var body: some View {
        Section(header: Text("RESULTS")
            .font(.headline)
            .foregroundColor(Color("AccentBlue"))
        ) {
            VStack(alignment: .center, spacing: 10) {
                Text("Estimated Body Fat:")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                Text("\(viewModel.bodyFatPercentage)%")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(viewModel.bodyFatPercentage == "0.0" ? .secondary : Color("ResultGreen"))
                    .animation(.easeIn, value: viewModel.bodyFatPercentage)

                Text(viewModel.calculationStatusMessage)
                    .font(.caption)
                    .foregroundColor(viewModel.calculationStatusColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
        }
    }
}

// Preview için ViewModel'ı sağlamak gerekiyor.
struct ResultsSection_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            ResultsSection(viewModel: BodyFatCalculatorViewModel())
        }
    }
}
