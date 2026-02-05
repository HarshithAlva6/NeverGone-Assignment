import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    
    init(session: ChatSession) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(session: session))
    }
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        if !viewModel.lastSummary.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("📝 Session Summary")
                                    .font(.headline)
                                    .foregroundColor(.purple)
                                Text(viewModel.lastSummary)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.bottom, 8)
                        }
                        
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                        
                        if viewModel.isStreaming && !viewModel.currentStreamingResponse.isEmpty {
                            HStack {
                                Text(viewModel.currentStreamingResponse)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(12)
                                Spacer()
                            }
                            .id("streaming_message")
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { _ in
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: viewModel.currentStreamingResponse) { _ in
                   proxy.scrollTo("streaming_message", anchor: .bottom)
                }
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                .foregroundColor(.red)
                .font(.caption)
                .padding(.horizontal)
            }
            
            HStack {
                TextField("Message...", text: $viewModel.inputMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(viewModel.isStreaming)
                
                if viewModel.isStreaming {
                    Button(action: viewModel.cancelStreaming) {
                        Image(systemName: "stop.circle.fill")
                            .foregroundColor(.red)
                            .font(.title2)
                    }
                } else {
                    Button(action: {
                        Task { await viewModel.sendMessage() }
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                    }
                    .disabled(viewModel.inputMessage.isEmpty)
                }
            }
            .padding()
        }
        .navigationTitle(viewModel.session.title ?? "Chat")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.isSummarizing {
                    ProgressView()
                } else {
                    Button("Summarize") {
                        Task { await viewModel.summarizeSession() }
                    }
                }
            }
        }
        .task {
            await viewModel.loadMessages()
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard let last = viewModel.messages.last else { return }
        withAnimation {
            proxy.scrollTo(last.id, anchor: .bottom)
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var isUser: Bool {
        message.role == .user
    }
    
    var body: some View {
        HStack {
            if isUser { Spacer() }
            
            Text(message.content)
                .padding()
                .background(isUser ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isUser ? .white : .primary)
                .cornerRadius(12)
            
            if !isUser { Spacer() }
        }
    }
}
