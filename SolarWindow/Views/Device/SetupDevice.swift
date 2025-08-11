import SwiftUI
import CoreBluetooth

struct ProvisioningView: View {
    @ObservedObject var bleManager: BLEManager
    var connectedDevice: CBPeripheral
    @State private var ssid = ""
    @State private var password = ""
    @State private var isSending = false
    @State private var showRetry = false
    @State private var moduleName: String = ""
    @Binding var path: [DeviceNavigation]
    
    var body: some View {
        VStack(spacing: 32) {
            
            VStack(spacing: 6) {
                Text("Let’s Connect Your Device")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text("Specify your network details")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    Image("solar-panel-open")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                    Text("Device")
                        .font(.headline)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Device Name")
                        .fontWeight(.medium)

                    TextField("e.g. Front Panel", text: $moduleName)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                        )
                        .autocapitalization(.none)
                        .disabled(isSending)

                    Text("This helps us identify your system in the dashboard")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    Image("network")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                    Text("Network")
                        .font(.headline)
                }

                VStack(spacing: 12) {
                    TextField("Wi-Fi Name", text: $ssid)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                        )
                        .autocapitalization(.none)
                        .disabled(isSending)

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                        )
                        .autocapitalization(.none)
                        .disabled(isSending)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
            
            if isSending {
                ProgressView("Connecting...")
                    .padding()
            }

            if showRetry {
                Text("Failed to connect. Try again or go back.")
                    .foregroundColor(.red)
                    .font(.subheadline)
            }

            Button(action: {
                sendToESP32()
            }) {
                Text("Connect")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isSending ? Color.gray : Color.orange)
                    .cornerRadius(14)
                    .shadow(color: .orange.opacity(0.3), radius: 6, x: 0, y: 4)
            }
            .disabled(isSending)
            .opacity(isSending ? 0.6 : 1.0)
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Device Setup")
        .navigationBarBackButtonHidden(isSending)
        .onDisappear {
            bleManager.disconnect(peripheral: connectedDevice)
        }
        .onAppear{
            bleManager.connect(to: connectedDevice)
        }
        .onChange(of: bleManager.ipAddress) { newIP in
            guard let ip = newIP, !ip.isEmpty else { return }

            isSending = false
            showRetry = false

            path.append(DeviceNavigation.setupLocation(name: moduleName, ipaddress: ip))
            bleManager.disconnect(peripheral: connectedDevice)
        }


    }

    private func sendToESP32() {
        isSending = true
        showRetry = false
        bleManager.ipAddress = nil

        bleManager.sendWiFiCredentials(ssid: ssid, password: password)

        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            if bleManager.ipAddress == nil {
                isSending = false
                showRetry = true
            }
        }
    }
}
