//
//  DeviceMenuViewModel.swift
//  SolarWindow
//
//  Created by Johny Lopez on 5/24/25.
//

import SwiftUI

class DeviceMenuViewModel: ObservableObject {
    @Published var devices: [IoTDevice] = []

    init() {
        loadDevices()
    }

    func loadDevices() {
        // Simulate loading devices (e.g., from network or local DB)
        devices = [
            IoTDevice(name: "Front Window", type: "window",ip_address: "http://192.168.10.36"),
                IoTDevice(name: "Roof", type: "roof", ip_address: "http://192.168.10.136")
//            IoTDevice(name: "Roof", type: "roof", ip_address: "http://192.168.10.98")
        ]
    }
}

extension Date {
    func formattedAsCustom() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yy"
        return formatter.string(from: self)
    }
}
