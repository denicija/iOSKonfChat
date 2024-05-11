import GRPC
import NIO
import NIOSSL

class ChatRoom {
    var chatRoomClient: ChatRoomAsyncClient?
    var group: MultiThreadedEventLoopGroup?
    var channel: GRPCChannel?
    var attendee: Attendee
    var chatMessages: ChatMessages
    var bidirectionalStream: GRPCAsyncBidirectionalStreamingCall<ChatMessage, ChatMessage>?
    
    init(attendee: Attendee, chatMessages: ChatMessages) {
        self.attendee = attendee
        self.chatMessages = chatMessages
    }
    
    deinit {
        do {
            try group?.syncShutdownGracefully()
            try channel?.close().wait()
        } catch {
            print("Error while shutting down: \(error)")
        }
    }
    
    func run() throws {
        group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        // Configure the channel, we're not using TLS so the connection is `insecure`.
        channel = try GRPCChannelPool.with(
            target: .host("localhost", port: 1234),
            transportSecurity: .plaintext,
            eventLoopGroup: group!
        )
        
        // Provide the connection to the generated client.
        chatRoomClient = ChatRoomAsyncClient(channel: channel!)
        connectToRoom()
    }
    
    func addMessage(message: ChatMessage) {
        Task {
            do {
                guard let bidirectionalStream = self.bidirectionalStream else {
                    print("Bidirectional stream is nil.")
                    return
                }
                try await bidirectionalStream.requestStream.send(message)
            } catch {
                print("Message failed: \(error)")
            }
        }
    }
    
    func connectToRoom() {
        guard let client = chatRoomClient else {
            print("Chat room client is nil.")
            return
        }
        
        bidirectionalStream = client.makeConnectCall()
        
        Task {
            guard let bidirectionalStream = self.bidirectionalStream else {
                print("Bidirectional stream is nil.")
                return
            }
            do {
                for try await response in bidirectionalStream.responseStream {
                    await MainActor.run {
                        chatMessages.addMessage(response)
                    }
                }
            } catch {
                print("Error while receiving message: \(error)")
            }
        }
    }
}

