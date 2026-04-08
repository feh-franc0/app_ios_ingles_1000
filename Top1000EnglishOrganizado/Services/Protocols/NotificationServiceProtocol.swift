import Foundation

/// Abstração de notificações — mock hoje, UNUserNotificationCenter futuramente
protocol NotificationServiceProtocol {
    func requestPermission() async -> Bool
    func scheduleDaily(hour: Int, minute: Int)
    func cancelAll()
}
