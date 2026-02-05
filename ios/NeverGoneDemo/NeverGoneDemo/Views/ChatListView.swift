import SwiftUI

struct ChatListView: View {
    @StateObject private var viewModel = ChatListViewModel()
    
    var body: some View {
        NavigationStack {
            List(viewModel.sessions) { session in
                NavigationLink(value: session) {
                    Text(session.title ?? "Untitled Chat")
                    Text(session.createdAt, style: .date)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Chats")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task { await viewModel.createSession() }
                    }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sign Out") {
                        Task { await viewModel.signOut() }
                    }
                }
            }
            .task {
                await viewModel.loadSessions()
            }
            .refreshable {
                await viewModel.loadSessions()
            }
            .navigationDestination(for: ChatSession.self) { session in
                ChatView(session: session)
            }
        }
    }
}
