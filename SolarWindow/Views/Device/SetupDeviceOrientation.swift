//
//  SetupDeviceOrientation.swift
//  SolarWindow
//
//  Created by Johny Lopez on 8/2/25.
//

import SwiftUI

struct SetupDeviceOrientation: View {
    let name: String
    let ipaddress: String
    let coordinates: Coordinates
    let locationName: String
    @State private var showHelpDetails = false
    @State private var orientationDegree:Double = 180
    @Binding var path: [DeviceNavigation]
    @ObservedObject var viewModel: DeviceMenuViewModel
    
    var body: some View {
        VStack(spacing: 24){
            VStack(spacing: 8) {
                Text("Which direction does your facade face?")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("This helps us understand your solar panel's current orientation")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true) // Allow wrapping
            }
            .frame(maxWidth: .infinity)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center) {
                    Image(systemName: "iphone")
                        .foregroundColor(.blue)
                    Text("Need help finding the direction?")
                        .font(.headline)
                    Spacer()
                    Button(action: {
                        withAnimation {
                            showHelpDetails.toggle()
                        }
                    }) {
                        Image(systemName: showHelpDetails ? "chevron.up.circle.fill" : "questionmark.circle.fill")
                            .foregroundColor(.blue)
                            .imageScale(.large)
                    }
                }

                if showHelpDetails {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .center) {
                            Image(systemName: "safari")
                                .foregroundColor(.blue)
                            Text("Use your phone's built-in compass app to find the direction")
                        }
                        HStack(alignment: .center) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                            Text("Stand facing the same direction as your solar panels")
                        }
                        HStack(alignment: .center) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                            Text("Note the compass reading and adjust the slider below")
                        }
                    }
                    .font(.caption)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(16)
            .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 16){
                HStack(alignment: .center) {
                    Image(systemName: "safari")
                        .foregroundColor(.orange)
                    Text("Facade Orientation")
                        .font(.headline)
                }
                
                VStack(alignment: .center, spacing: 16) {
                    Text("Current orientation reading")
                        .font(.subheadline)
                    Text("\(Int(orientationDegree))°")
                        .foregroundColor(.orange)
                        .font(.title)
                        .bold()
                    Slider(value: $orientationDegree, in: 0...360, step: 1)
                        .accentColor(.black)
                    HStack(alignment: .center){
                        Text("N (0)°")
                        Spacer()
                        Text("E (90)°")
                        Spacer()
                        Text("S (180)°")
                        Spacer()
                        Text("W (270)°")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                    
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 3)
                            .frame(width: 160, height: 160)
                        Circle()
                            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                            .frame(width: 140, height: 140)
                        Group {
                            Text("N")
                                .font(.headline).bold()
                                .position(x: 100, y: 30)
                            Text("E")
                                .font(.headline).bold()
                                .position(x: 170, y: 100)
                            Text("S")
                                .font(.headline).bold()
                                .position(x: 100, y: 170)
                            Text("W")
                                .font(.headline).bold()
                                .position(x: 30, y: 100)
                        }

                        Image(systemName: "location.north.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 100)
                            .foregroundColor(.orange)
                            .rotationEffect(Angle(degrees: orientationDegree))
                            .animation(.easeInOut(duration: 0.2), value: orientationDegree)

                    }
                    .frame(width: 200, height: 200)
                }
                
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
            Button(action: {
                viewModel.addDevice(ipaddress: ipaddress, name: name, orientation: orientationDegree, location: coordinates, locationName: locationName)
                path.append(DeviceNavigation.setupCompleted)
            }) {
                Text("Complete Setup")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(14)
                    .shadow(color: .orange.opacity(0.3), radius: 6, x: 0, y: 4)
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Device Setup")
    }
    
}
