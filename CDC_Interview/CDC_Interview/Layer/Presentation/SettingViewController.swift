
import UIKit
import RxSwift
import RxCocoa
import SwiftUI

typealias SettingViewController = UIHostingController<SettingView>


struct SettingView: View {
    @StateObject var viewModel: SettingModel = .init()
    var body: some View {
        VStack {
            Toggle("Support EUR", isOn: $viewModel.supportEUR)
        }
    }
}

class SettingModel: ObservableObject {
    @Published var supportEUR: Bool = false {
        didSet {
            featureFlagProvider.update(flag: .supportEUR, newValue: supportEUR)
        }
    }
    
    let featureFlagProvider: FeatureFlagProviderProtocol

    init() {
        self.featureFlagProvider = Dependency.shared.resolve(FeatureFlagProviderProtocol.self)!
        self.supportEUR = self.featureFlagProvider.getValue(flag: .supportEUR)
    }
}

#Preview {
    SettingView(viewModel: .init())
}
