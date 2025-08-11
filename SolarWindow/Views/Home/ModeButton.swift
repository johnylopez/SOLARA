import SwiftUI

struct ModeButton: View {
    var title: String
    var icon: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(.white)
//                    .padding(20) 
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            .frame(width: 100, height: 100) 
            .background(Color.blue)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
    }
}
