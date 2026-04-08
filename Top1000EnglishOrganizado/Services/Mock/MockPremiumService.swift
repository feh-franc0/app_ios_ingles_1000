import Foundation
import Combine

/// Mock de compras — simula fluxo sem StoreKit real
final class MockPremiumService: PremiumServiceProtocol, ObservableObject {
    @Published private(set) var isPremium: Bool = false

    func purchase(plan: PremiumPlan) async -> PurchaseResult {
        // Simula delay de rede
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        await MainActor.run { isPremium = true }
        return .success
    }

    func restorePurchases() async -> Bool {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        return isPremium
    }
}
