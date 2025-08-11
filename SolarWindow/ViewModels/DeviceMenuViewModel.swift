//
//  DeviceMenuViewModel.swift
//  SolarWindow
//
//  Created by Johny Lopez on 5/24/25.
//

import SwiftUI

//class DeviceMenuViewModel: ObservableObject {
//    @Published var devices: [IoTDevice] = []
//
//    init() {
//        loadDevices()
//    }
//
//    private func loadDevices() {
//        // Simulate loading devices (e.g., from network or local DB)
//        devices = [
//            IoTDevice(name: "Front Window", type: "window",ip_address: "http://192.168.10.36"),
//                IoTDevice(name: "Roof", type: "roof", ip_address: "http://192.168.10.136")
////            IoTDevice(name: "Roof", type: "roof", ip_address: "http://192.168.10.98")
//        ]
//    }
//    
//    
//    //MARK: - Intents
//    func addDevice(ipaddress: String) {
//        devices.append(IoTDevice(name: "Front Window \(devices.count + 1)", type: "window", ip_address: "http://\(ipaddress)"))
//    }
//}

class DeviceMenuViewModel: ObservableObject {
    @Published var devices: [IoTDevice] = [] {
        didSet {
            saveDevices()
        }
    }

    private let devicesKey = "storedIoTDevices"

    init() {
        loadDevices()
    }

    func addDevice(ipaddress: String, name: String, orientation: Double, location: Coordinates, locationName: String) {
        let newDevice = IoTDevice(
            name: name,
            type: "window",
            orientation: orientation,
            ip_address: "http://\(ipaddress)",
            location: Coordinates(latitude: location.latitude, longitude: location.longitude),
            locationName: locationName
        )
        devices.append(newDevice)
        print(devices)
    }
    
    func removeDevice(byIP ip: String) {
        devices.removeAll { $0.ip_address == ip }
    }
    
    func clearDevices() {
        devices.removeAll()
        UserDefaults.standard.removeObject(forKey: devicesKey)
    }

    private func saveDevices() {
        do {
            let data = try JSONEncoder().encode(devices)
            UserDefaults.standard.set(data, forKey: devicesKey)
        } catch {
            print("Failed to save devices:", error)
        }
    }

    private func loadDevices() {
        guard let data = UserDefaults.standard.data(forKey: devicesKey) else { return }
        do {
            devices = try JSONDecoder().decode([IoTDevice].self, from: data)
        } catch {
            print("Failed to load devices:", error)
        }
    }
}

extension Date {
    func formattedAsCustom() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yy"
        return formatter.string(from: self)
    }
}
