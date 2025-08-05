
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
            featureFlagProvider.update(falg: .supportEUR, newValue: supportEUR)
        }
    }
    
    let featureFlagProvider: FeatureFlagProvider
    
    init() {
        self.featureFlagProvider = Dependency.shared.resolve(FeatureFlagProvider.self)!
        self.supportEUR = self.featureFlagProvider.getValue(falg: .supportEUR)
    }
}

#Preview {
    SettingView(viewModel: .init())
}
