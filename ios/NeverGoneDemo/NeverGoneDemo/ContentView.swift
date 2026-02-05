import SwiftUI

struct ContentView: View {
    @StateObject private var authService = AuthService.shared
    
    var body: some View {
        Group {
            if authService.session != nil {
                ChatListView()
            } else {
                LoginView()
            }
        }
    }
}
