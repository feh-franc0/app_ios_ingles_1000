import Foundation

/// Abstração de compras — hoje é mock, futuramente usa StoreKit 2
protocol PremiumServiceProtocol {
    var isPremium: Bool { get }
    func purchase(plan: PremiumPlan) async -> PurchaseResult
    func restorePurchases() async -> Bool
}

enum PremiumPlan: String, CaseIterable {
    case monthly = "Mensal"
    case yearly  = "Anual"

    var price: String {
        switch self {
        case .monthly: return "R$ 19,90/mês"
        case .yearly:  return "R$ 99,90/ano"
        }
    }

    var savings: String? {
        switch self {
        case .monthly: return nil
        case .yearly:  return "Economize 58%"
        }
    }
}

enum PurchaseResult {
    case success
    case cancelled
    case failed(String)
}
