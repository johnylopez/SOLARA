//
//  HomeView.swift
//  SolarWindow
//
//  Created by Johny Lopez on 1/18/25.
//

import SwiftUI
import SceneKit

struct HomeView: View {
    @ObservedObject var homeVM: HomeViewModel
    private let servoDegreeOffset: Double = 90
    
    var body: some View {
        ZStack{
            if homeVM.isDaytime {
                Rectangle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.6)]),
                        startPoint: .top,
                        endPoint: .bottom)
                    )
                    .edgesIgnoringSafeArea(.all)
            } else {
                Rectangle()
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.7)]), startPoint: .top, endPoint: .bottom))
                    .edgesIgnoringSafeArea(.all)
                    
                Image(systemName: "moon.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.white)
                    .position(x: 300, y: 150)
                
                ForEach(0..<100, id: \.self) { _ in
                    Circle()
                        .fill(Color.white.opacity(0.7))
                        .frame(width: 2, height: 2)
                        .position(
                            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                            y: CGFloat.random(in: 100...UIScreen.main.bounds.height / 2)
                        )
                }
            }
            VStack {
                VStack(spacing: 4) {
                    Text("Solar Window")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("East-facing Window")
                        .font(.subheadline)
                        .foregroundColor(homeVM.isDaytime ? .black : .white)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .top)
                VStack{
                    if(homeVM.isDaytime) {
                        ZStack {
                            // Reflected sun
                            VStack {
                                Circle()
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [Color.yellow.opacity(0.5), Color.orange.opacity(0.3)]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ))
                                    .frame(width: 100, height: 100)
                                    .scaleEffect(1.0)
                                    .blur(radius: 20)
                                    .opacity(0.5)
                                    .offset(y: 40)
                            }
                
                            // Glowing sun with arc movement
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                ))
                                .frame(width: 100, height: 100)
                                .shadow(color: Color.orange.opacity(0.8), radius: 25) // Steady glowing effect
                        }
                        .padding(.bottom, 420)
                        .offset(
                            x: homeVM.getSunPositionX(degree: homeVM.sunDegree),
                            y: homeVM.getSunPositionY(degree: homeVM.sunDegree)
                        )
                        .rotationEffect(.degrees(180))
                    }
                   
                }
                .frame(height: 175)
                

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
                                .degrees(homeVM.currentMode == "Open" || homeVM.currentMode == "Manual"
                                    ? homeVM.rotationDegree - servoDegreeOffset - 1
                                    : homeVM.rotationDegree - servoDegreeOffset),
                                axis: (x: 0, y: 1, z: 0), // Horizontal swivel
                                perspective: 0.8
                            )
                            .animation(.easeInOut(duration: 1.5), value: homeVM.rotationDegree)
                        }
                        
                    }
                    .padding(.bottom, 50)
                    VStack(spacing: 4) {
                        Text("\((abs(Int(homeVM.rotationDegree) - Int(servoDegreeOffset))))° \(Int(homeVM.rotationDegree) - Int(servoDegreeOffset) >= 0 ? "N" : "S")")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Mode")
                            .font(.subheadline)
                            .foregroundColor(homeVM.isDaytime ? .black : .white)
                        Text(homeVM.currentMode)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    HStack(spacing: 20) {
                        Button(action: {
                            homeVM.setMode(mode: "Open")
                        }) {
                            VStack {
                                Image("solar-panel-open")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                Text("Open")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        }
                        Button(action: {
                            homeVM.setMode(mode: "Closed")
                        }) {
                            VStack {
                                Image("solar-panel-close")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                Text("Closed")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        }
                        Button(action: {
                            homeVM.setMode(mode: "Sun Tracking")
                        }) {
                            VStack {
                                Image("solar-panel-track")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                Text("Track")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        }
                        Button(action: {
                            homeVM.setMode(mode: "Manual")
                        }) {
                            VStack {
                                Image("manual")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                Text("Manual")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        }
                    }
                        .padding(10)
                    Spacer()
                }
                VStack {
                    if homeVM.currentMode == "Manual" {
                        Text("Move slider to set position:")
                            .font(.title3)
                            .foregroundColor(.black)
            
                        Slider(value: $homeVM.rotationDegree, in: 0...180, step: 1) {
                            Text("Servo Position")
                        }
                        .onChange(of: homeVM.rotationDegree) { newValue in
                            homeVM.updateServoPosition(degree: newValue)
                        }
                        .padding()
                    }
                } 
                .frame(height: 100)
                Spacer()
            }
        }
    }
}

