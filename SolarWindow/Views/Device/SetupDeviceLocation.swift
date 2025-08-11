import SwiftUI
import MapKit
import CoreLocation
import Foundation

struct SetupDeviceLocation: View {
    let name: String
    let ipaddress: String
    @StateObject private var locationManager = LocationManager()
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var locationName: String?
    @Binding var path: [DeviceNavigation]
    
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Where is your building?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("We need your location to calculate optimal solar angles")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.orange)
                    Text("Building Location")
                        .font(.headline)
                }
                
                if let region = locationManager.region {
                    Map(initialPosition: .region(region)) {
                        if let selected = selectedLocation {
                            Marker("Selected", coordinate: selected)
                        }
                        UserAnnotation()
                    }
                    .mapControls {
                        MapUserLocationButton()
                        MapCompass()
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .onTapGesture {
                        selectedLocation = region.center
                        fetchLocationName(from: region.center)
                    }
                } else {
                    ProgressView("Loading map...")
                        .frame(height: 200)
                }
                
                if let loc = selectedLocation {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Selected Location:")
                            .font(.headline)
                        if let location = locationName {
                            Text(location)
                                .foregroundColor(.blue)
                                .fontWeight(.semibold)
                        }
                        Text("Lat: \(loc.latitude), Lon: \(loc.longitude)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("Tap the map to select the center location.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
            
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundColor(.blue)
                    Text("Why do we need this?")
                        .font(.headline)
                }
                Group {
                    Text("• Calculate precise sun angles for your location")
                    Text("• Optimize panel rotation schedule")
                    Text("• Provide accurate weather and solar data")
                }
                .font(.subheadline)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(16)
            .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
            
            // Confirm Button
            Button(action: {
                if let loc = selectedLocation {
                    if let location = locationName {
                        path.append(DeviceNavigation.setupOrientation(name: name, ipaddress: ipaddress, coodinates: Coordinates(latitude: loc.latitude, longitude: loc.longitude), locationName: location))
                    }
                }
            }) {
                Text("Set Location")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(14)
                    .shadow(color: .orange.opacity(0.3), radius: 6, x: 0, y: 4)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Device Setup")

    }
    
    private func fetchLocationName(from coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                let city = placemark.locality ?? ""
                let state = placemark.administrativeArea ?? ""
                let country = placemark.country ?? ""
                
                var components = [String]()
                if !city.isEmpty { components.append(city) }
                if !state.isEmpty { components.append(state) }
                if !country.isEmpty { components.append(country) }
                
                locationName = components.joined(separator: ", ")
            } else {
                locationName = "Unknown location"
            }
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var region: MKCoordinateRegion?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else { return }

        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(
                center: loc.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
}
