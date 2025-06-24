import SwiftUI

struct MenuView: View {
    @StateObject private var viewModel = DeviceMenuViewModel()
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                Color(.systemGray6)
                    .ignoresSafeArea()

                // Main content
                VStack(alignment: .leading) {

                    // 📊 Energy Summary Card
                    HStack {
                        VStack(alignment: .center) {
                            HStack {
                                Text("Energy Generated")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                Spacer()
                                HStack(alignment: .center) {
                                    Image("calendar")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .padding(.horizontal)
                                    Text(Date().formattedAsCustom())
                                        .font(.subheadline)
                                        
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            
                            Divider()
                               .frame(height: 1)
                               .background(Color.gray.opacity(0.4))
                               .padding(.horizontal)
                               .padding(.vertical, 5)
                            
                            HStack {
                                HStack {
                                    Image("daily_gen")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .padding(.horizontal)
                                    VStack {
                                        Text("Today")
                                            .font(.caption)
                                        Text("9 kWh")
                                            .font(.title2)
                                    }
                                    
                                }
                                .frame(maxWidth: .infinity)
                                
                               
                                HStack {
                                    Image("monthly_gen")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                    VStack {
                                        Text("This Month")
                                            .font(.caption)
                                        Text("31.5 kWh")
                                            .font(.title2)
                                    }
                                    
                                }
                                .frame(maxWidth: .infinity)
                                
                            }
                        }
                        .padding(.vertical, 12)
                        .background(Color(.white))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)

                    // 🖼 Section Title
                    Text("Devices:")
                        .font(.headline)
                        .padding(.horizontal)

                    // 📱 Devices Grid
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.devices) { device in
                            NavigationLink(destination: HomeView(homeVM: HomeViewModel(device: device))) {
                                DeviceCardView(device: device)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)

                    Spacer()

                    // 📍 Footer
                    HStack {
                        Spacer()
                        Text("Solara ®")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.bottom, 8)
                }
                .padding(.top)
                .navigationTitle("Welcome Home")
            }
        }
    }

    
}
