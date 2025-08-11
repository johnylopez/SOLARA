import SwiftUI
import CoreBluetooth

struct DeviceListView: View {
    @ObservedObject var bleManager = BLEManager()
    @Binding var path: [DeviceNavigation]
    @State private var selectedDevice: CBPeripheral? = nil

    var body: some View {
        VStack {
            List(bleManager.devices, id: \.identifier) { device in
                Button(action: {
                    selectedDevice = device
                }) {
                    Text(device.name ?? "Unnamed")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) 
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Nearby Devices")
        .navigationDestination(item: $selectedDevice) { device in
            ProvisioningView(
                bleManager: bleManager,
                connectedDevice: device,
                path: $path
            )
        }
    }

}

