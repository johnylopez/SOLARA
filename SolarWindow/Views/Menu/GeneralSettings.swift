import SwiftUI

struct GeneralSettings: View {
    @State private var showClearAlert = false
    @State private var statusMessage = ""
    @ObservedObject var viewModel: DeviceMenuViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            VStack(alignment: .leading, spacing: 8) {
                Text("General")
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Devices")
                    .font(.headline)

                Button {
                    showClearAlert = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Clear All Devices")
                    }
                    .foregroundColor(.red)
                }
            }

            if !statusMessage.isEmpty {
                Text(statusMessage)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .alert("Clear All Devices?", isPresented: $showClearAlert) {
            Button("Clear", role: .destructive) {
                viewModel.clearDevices()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will remove all paired devices. This action cannot be undone.")
        }
    }
}
