
import SwiftUI

struct ChatMessage: Identifiable, Equatable {
    enum Role {
        case user
        case assistant
    }

    let id = UUID()
    let role: Role
    let content: String
}

struct ChatView: View {
    @StateObject private var chatService = ChatService.shared
    @State private var inputText: String = ""
    @State private var isSending: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(chatService.messages) { message in
                            messageBubble(for: message)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                }
                .background(Color.black.edgesIgnoringSafeArea(.all))
                .onChange(of: chatService.messages) { _ in
                    if let last = chatService.messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }

            inputBar
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.black)
        }
    }

    private func messageBubble(for message: ChatMessage) -> some View {
        HStack {
            if message.role == .assistant { Spacer() }

            Text(message.content)
                .foregroundColor(.white)
                .padding(12)
                .background(
                    message.role == .user
                    ? Color(white: 0.2)
                    : Color(red: 0.05, green: 0.12, blue: 0.25)
                )
                .cornerRadius(18)

            if message.role == .user { Spacer() }
        }
        .animation(.easeInOut(duration: 0.18), value: chatService.messages)
    }

    private var inputBar: some View {
        HStack(spacing: 8) {
            TextField("Message KORA…", text: $inputText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...4)
                .disableAutocorrection(false)
                .submitLabel(.send)
                .onSubmit { send() }

            Button {
                send()
            } label: {
                if isSending {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else {
                    Text("Send")
                        .fontWeight(.semibold)
                }
            }
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
        }
    }

    private func send() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        inputText = ""
        isSending = true

        ChatService.shared.sendMessage(trimmed) { _ in
            DispatchQueue.main.async {
                self.isSending = false
            }
        }
    }
}
