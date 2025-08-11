//
//  WindowPanel.swift
//  SolarWindow
//
//  Created by Johny Lopez on 5/26/25.
//

import SwiftUI

struct WindowPanel: View {
    let currentMode: String
    let rotationDegree: Double
    let servoDegreeOffset: Double
    
    var body: some View {
        VStack {
            VStack() {
                ZStack {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 20, height: 125)
                        .cornerRadius(10)
                        .offset(y: 50) //
                    ZStack {
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: 100, height: 100)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                        Image("panel")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                    }
                    .rotationEffect(.degrees(45))
                    .rotation3DEffect(
                        .degrees(currentMode == "Open" || currentMode == "Manual"
                            ? rotationDegree - servoDegreeOffset - 1
                            : rotationDegree - servoDegreeOffset),
                        axis: (x: 0, y: 1, z: 0), // Horizontal swivel
                        perspective: 0.8
                    )
                    .animation(.easeInOut(duration: 1.5), value: rotationDegree)
                }
                
            }
            .padding(.bottom, 50)
            Text("\((abs(Int(rotationDegree) - Int(servoDegreeOffset))))° \(Int(rotationDegree) - Int(servoDegreeOffset) >= 0 ? "N" : "S")")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        
    }
}

