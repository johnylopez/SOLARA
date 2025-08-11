//
//  DeviceModel.swift
//  SolarWindow
//
//  Created by Johny Lopez on 5/24/25.
//

import Foundation

struct Coordinates: Codable, Hashable {
    var latitude: Double
    var longitude: Double
}

struct IoTDevice: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String
    var type: String
    var orientation: Double
    var ip_address: String
    var location: Coordinates
    var locationName: String
}
