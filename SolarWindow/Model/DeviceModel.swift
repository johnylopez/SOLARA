//
//  DeviceModel.swift
//  SolarWindow
//
//  Created by Johny Lopez on 5/24/25.
//

import Foundation

struct IoTDevice: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let ip_address: String
}


