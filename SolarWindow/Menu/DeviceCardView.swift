//
//  DeviceCardView.swift
//  SolarWindow
//
//  Created by Johny Lopez on 5/24/25.
//

import SwiftUI

struct DeviceCardView: View {
    let device: IoTDevice

    var body: some View {
        VStack(spacing: 10) {
            Image("solar-panel-open")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60
                )
            Text(device.name)
                .font(.headline)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.white))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}


