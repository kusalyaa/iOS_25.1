import SwiftUI

@main
struct kusalya_ios_applicationApp: App {
    @StateObject private var sessionStore = SessionStore()
    @StateObject private var locationService = LocationService()
    @StateObject private var notificationService = NotificationService()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                   .environmentObject(sessionStore)
                   .environmentObject(locationService)
                   .environmentObject(notificationService)
                   .onAppear {
                       locationService.requestPermissionAndStart()
                   }
        }
    }
}
