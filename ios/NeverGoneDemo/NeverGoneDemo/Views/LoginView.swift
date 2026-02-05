import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("NeverGone")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
            
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            if viewModel.isLoading {
                ProgressView()
            } else {
                HStack {
                    Button("Sign In") {
                        Task { await viewModel.signIn() }
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Sign Up") {
                        Task { await viewModel.signUp() }
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding()
    }
}
