import SwiftUI

struct ChatRoomView: View {
    @State private var newMessage: String = ""
    @ObservedObject private var messages: ChatMessages
    var chatRoom: ChatRoom!
    var attendee: Attendee
    
    init() {
        self.messages = ChatMessages()
        // Simulate an actual attendee
        self.attendee = Attendee()
        self.attendee.name = "User \(arc4random())"
        self.chatRoom = ChatRoom(attendee: self.attendee, chatMessages: self.messages)
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach($messages.messages, id: \.self) { $chatMessage in
                        HStack {
                            if chatMessage.attendee.name == attendee.name {
                                Spacer()
                                Text(chatMessage.textMessage)
                                    .padding(8)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else {
                                VStack(alignment: .leading) {
                                    Text(chatMessage.attendee.name)
                                        .font(.caption)
                                    Text(chatMessage.textMessage)
                                        .padding(8)
                                        .background(Color.gray)
                                        .foregroundColor(.black)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                Spacer()
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            HStack {
                TextField("Type your message", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: sendMessage) {
                    Text("Send")
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.trailing)
            }
            .padding(.bottom)
        }
        .navigationTitle("Chat Room")
        .onAppear {
            do {
                try chatRoom.run()
            } catch {
                print("Error running chat room: \(error)")
            }
        }
    }
    
    func sendMessage() {
        guard !newMessage.isEmpty else { return }
        let message = ChatMessage.with {
            $0.attendee = attendee
            $0.textMessage = newMessage
        }
        chatRoom.addMessage(message: message)
        newMessage = ""
    }
}

struct ChatRoomView_Previews: PreviewProvider {
    static var previews: some View {
        ChatRoomView()
    }
}

