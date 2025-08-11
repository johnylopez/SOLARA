//
//  RoofPanel.swift
//  SolarWindow
//
//  Created by Johny Lopez on 5/26/25.
//

import SwiftUI

struct RoofPanel: View {
    let currentMode: String
    let rotationDegree: Double
    
    var effectiveRotation: Double {
        switch currentMode {
        case "Open":
            return 0.0
        case "Manual":
            return 181 - rotationDegree
        case "Closed":
            return rotationDegree - 5
        case "Sun Tracking":
            return 181 - rotationDegree
        default:
            return 0
        }
    }
    
    var body: some View {
        VStack {
            VStack() {
                ZStack {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 20, height: 125)
                        .cornerRadius(10)
                        .offset(y: 50)
                    ZStack {
                        if effectiveRotation <= 90 {
                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: 100, height: 100)
                                .cornerRadius(10)
                                .shadow(radius: 10)
                            Image("panel")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 90, height: 90)
                        } else {
                            Rectangle()
                                .fill(Color.gray)
                                .frame(width: 100, height: 100)
                                .cornerRadius(10)
                                .shadow(radius: 10)
                            
                        }
                        
                    }
                    .rotation3DEffect(
                        .degrees(effectiveRotation),
                        axis: (x: 1, y: 0, z: 0), // Horizontal swivel
                        perspective: 0.8
                    )
                    .animation(.easeInOut(duration: 1.5), value: effectiveRotation)
                    
                }
                
            }
            .padding(.bottom, 50)
            Text("\((abs(Int(rotationDegree) - 90)))° \(Int(rotationDegree) - 90 >= 0 ? "W" : "E")")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        
    }
}
