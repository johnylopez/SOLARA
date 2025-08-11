//
//  CompletedSetup.swift
//  SolarWindow
//
//  Created by Johny Lopez on 7/28/25.
//

import SwiftUI

struct SetupCompleteView: View {
    @Binding var path: [DeviceNavigation]
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Setup Completed")
                .font(.largeTitle)
                .fontWeight(.bold)


            Button("Go to Home") {
                path.removeLast(path.count)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }
}
