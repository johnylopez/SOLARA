//
//  HomeViewModel.swift
//  SolarWindow
//
//  Created by Johny Lopez on 1/18/25.
//

import SwiftUI
import Foundation
import Combine

class HomeViewModel: ObservableObject {
    let device: IoTDevice
    
    @Published private(set) var homeModel: Home
    @Published var rotationDegree: Double = 90
    @Published var sunDegree: Double = 0
    @Published var currentMode: String
    @Published var isDaytime: Bool = true
    @Published var deviceName: String
    @Published var deviceType: String
    @Published var deviceOrientation: Double
    @Published var deviceLocation: String
    private var timerSubscription: AnyCancellable?
    private var dayTimerSubscription: AnyCancellable?
    private var trackingTimerSubscription: AnyCancellable?
    
    private let minDegree: Double = 30
    private let maxDegree: Double = 150
    
    init(device: IoTDevice) {
        self.device = device
        homeModel = Home(device: device)
        currentMode = "Disconnected"
        deviceName = device.name
        deviceType = device.type
        deviceOrientation = device.orientation
        deviceLocation = device.locationName
        getCurrentMode()
        getCurrentDegree()
        startTimeUpdateTimer()
        updateDaytimeStatus()
        updateSunPositionBasedOnCurrentTime()
        startSunMovement()
    }
    
    
    
    private func startTimeUpdateTimer() {
        dayTimerSubscription = Timer.publish(every: 60, on: .main, in: .common)
           .autoconnect()
           .sink { [weak self] _ in
               self?.updateDaytimeStatus()
           }
    }

    private func updateDaytimeStatus() {
        let currentDate = Date()
        let hour = Calendar.current.component(.hour, from: currentDate)
        self.isDaytime = hour >= 6 && hour < 18
        if(!self.isDaytime && self.currentMode == "Sun Tracking") {
            self.rotationDegree = 90
            sendRequest(endpoint: "/servo/manual", degree: rotationDegree)
        }else if(self.isDaytime && self.currentMode == "Sun Tracking") {
            updateSunPositionBasedOnCurrentTime()
        }
    }
    
    private func updateSunPositionBasedOnCurrentTime() {
        let currentDate = Date()
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: currentDate)
        let minute = calendar.component(.minute, from: currentDate)
        

        let totalMinutesInDay = 12 * 60 // From 6 AM to 6 PM
        let currentMinutesInDay = (hour - 6) * 60 + minute
        

        let degreeRange = maxDegree - minDegree
        let degreeIncrement = (degreeRange / Double(totalMinutesInDay)) * Double(currentMinutesInDay)
        
        
        self.sunDegree = minDegree + degreeIncrement
        if(self.currentMode == "Sun Tracking") {
            if(self.isDaytime) {
                self.rotationDegree = minDegree + degreeIncrement
                sendRequest(endpoint: "/servo/manual", degree: self.rotationDegree)
            }else {
                self.rotationDegree = 90
            }
        }
        
    }
    private func startSunMovement() {
        timerSubscription = Timer.publish(every: 6 * 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateSunPositionBasedOnCurrentTime()
            }
    }
    
    private func stopSunMovement() {
        timerSubscription?.cancel()
    }
    
    private func startTrackingTimer() {
        trackingTimerSubscription = Timer.publish(every: 6 * 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.getCurrentDegree()
            }
    }
    
    private func stopTrackingTimer() {
        trackingTimerSubscription?.cancel()
    }
    
    private func trackingUpdate() {
        updateSunPositionBasedOnCurrentTime()
        sendRequest(endpoint: "/servo/manual", degree: self.rotationDegree)
    }
    
    func getCurrentMode() {
        homeModel.sendRequestForMode(endpoint: "/servo/mode") { responseBody in
            if let response = responseBody {
                print(response)
                DispatchQueue.main.async {
                    self.currentMode = response
                }
                
                if(response == "Sun Tracking") {
                    self.updateSunPositionBasedOnCurrentTime()
                }
            } else {
                print("Failed to fetch mode.")
            }
        }
    }
    
    private func getCurrentDegree() {
        homeModel.sendRequestForMode(endpoint: "/servo/degree") { responseBody in
            if let response = responseBody {
                print(response)
                DispatchQueue.main.async {
                    if let degree = Double(response) {
                        self.rotationDegree = degree
                        print(degree)
                    } else {
                        print("Error: Unable to convert response '\(response)' to Double.")
                    }
                }
            } else {
                print("Failed to fetch mode.")
            }
        }
    }
    
    //MARK: - Intents
    private func sendRequest(endpoint: String, degree: Double) {
        homeModel.sendRequest(endpoint: endpoint, degree: degree)
    }
    
    func getSunPositionX(degree: Double) -> Double {
        return homeModel.sunPositionX(degree: degree)
    }
    
    func getSunPositionY(degree: Double) -> Double {
        return homeModel.sunPositionY(degree: degree)
    }
    
    func apicall() {
        homeModel.apiCall()
    }
    
    func updateServoPosition(degree: Double){
        sendRequest(endpoint: "/servo/manual", degree: degree)
    }
    
    func setMode(mode: String) {
        if(currentMode != mode && currentMode != "Disconnected") {
            switch mode {
            case "Closed":
                self.rotationDegree = 90 
                self.currentMode = "Closed"
                sendRequest(endpoint: "/servo/closed", degree: 90)
                stopTrackingTimer()
            case "Open":
                self.rotationDegree = 180
                self.currentMode = "Open"
                sendRequest(endpoint: "/servo/open", degree: 180)
                stopTrackingTimer()
            case "Sun Tracking":
                self.currentMode = "Sun Tracking"
                updateSunPositionBasedOnCurrentTime()
                sendRequest(endpoint: "/servo/manual", degree: self.rotationDegree)
//                sendRequest(endpoint: "/servo/setSunTracking", degree: self.)
//                getCurrentDegree()
                startTrackingTimer()
                
            case "Manual":
                sendRequest(endpoint: "/servo/setManual", degree: 0)
                self.currentMode = "Manual"
                stopTrackingTimer()
            default:
                print("")
            }
        }
        
    }
}
