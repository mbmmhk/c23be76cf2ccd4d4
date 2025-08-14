
import UIKit
import RxSwift
import RxCocoa
import SwiftUI

typealias SettingViewController = UIHostingController<SettingView>


struct SettingView: View {
    @StateObject var viewModel: SettingViewModel = .init()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Custom large title
            Form {
                HStack {
                    Text("Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                }
                
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Support EUR")
                                .font(.body)
                            Text("Display EUR prices alongside USD prices")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: $viewModel.supportEUR)
                            .labelsHidden()
                    }
                    .padding(.vertical, 4)
                    .listRowBackground(Color.clear)
                } header: {
                    Text("Currency Settings")
                } footer: {
                    Text("When enabled, EUR prices will be shown in addition to USD prices in the cryptocurrency list.")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
    }
}

#Preview {
    SettingView(viewModel: .init())
}
