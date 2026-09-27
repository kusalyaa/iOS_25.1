import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "gamecontroller")
            }

            NavigationStack {
                StatsTab()
            }
            .tabItem {
                Label("Stats", systemImage: "chart.bar")
            }

            NavigationStack {
                MapTab()
            }
            .tabItem {
                Label("Map", systemImage: "map")
            }

            NavigationStack {
                SettingsTab()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
    }
}
