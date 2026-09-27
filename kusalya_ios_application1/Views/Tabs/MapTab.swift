import SwiftUI
import MapKit

struct MapTab: View {
    @EnvironmentObject var sessionStore: SessionStore
    @EnvironmentObject var locationService: LocationService

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),
        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
    )

    private var sessionsWithLocation: [GameSession] {
        sessionStore.sessions.filter { session in
            session.latitude != 0.0 && session.longitude != 0.0
        }
    }

    var body: some View {
        ZStack {
            if sessionsWithLocation.isEmpty {
                emptyMapView
            } else {
                mapView
            }
        }
        .navigationTitle("Game Map")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            locationService.requestPermissionAndStart()
            updateRegionToCurrentLocation()
        }
    }

    private var mapView: some View {
        Map(coordinateRegion: $region, annotationItems: sessionsWithLocation) { session in
            MapAnnotation(
                coordinate: CLLocationCoordinate2D(
                    latitude: session.latitude,
                    longitude: session.longitude
                )
            ) {
                VStack(spacing: 6) {
                    Image(systemName: session.mode.iconName)
                        .font(.title2)
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(Color.blue)
                        .clipShape(Circle())

                    VStack(spacing: 2) {
                        Text(session.mode.title)
                            .font(.caption)
                            .bold()

                        Text("Score: \(session.score)")
                            .font(.caption2)
                    }
                    .padding(6)
                    .background(Color.white)
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private var emptyMapView: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.black,
                    Color.green.opacity(0.75),
                    Color.mint.opacity(0.45)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 18) {
                Image(systemName: "map.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.white)

                Text("No Game Locations Yet")
                    .font(.system(size: 32, weight: .black))
                    .foregroundStyle(.white)

                Text("Complete a game after allowing location permission. Your completed sessions will appear as pins here.")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.75))
                    .multilineTextAlignment(.center)

                Button {
                    locationService.requestPermissionAndStart()
                    updateRegionToCurrentLocation()
                } label: {
                    Text("Enable Location")
                        .font(.headline)
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.top, 8)
            }
            .padding()
        }
    }

    private func updateRegionToCurrentLocation() {
        guard let coordinate = locationService.currentLocation else {
            return
        }

        region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        )
    }
}
