import Foundation

class ChatMessages: ObservableObject {
    @Published var messages: [ChatMessage] = []
    
    func addMessage(_ message: ChatMessage) {
        messages.append(message)
    }
}
