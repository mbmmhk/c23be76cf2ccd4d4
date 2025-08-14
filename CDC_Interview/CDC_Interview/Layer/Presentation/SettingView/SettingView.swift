
import UIKit
import RxSwift
import RxCocoa
import SwiftUI

typealias SettingViewController = UIHostingController<SettingView>


struct SettingView: View {
    @StateObject var viewModel: SettingViewModel = .init()

    var body: some View {
        NavigationView {
            Form {
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
                } header: {
                    Text("Currency Settings")
                } footer: {
                    Text("When enabled, EUR prices will be shown in addition to USD prices in the cryptocurrency list.")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    SettingView(viewModel: .init())
}
