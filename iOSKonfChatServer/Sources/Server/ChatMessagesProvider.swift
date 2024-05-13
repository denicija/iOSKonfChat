import GRPC
import NIOCore
import SwiftProtobuf

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
final actor StreamActor {
    private var responseStreams = [GRPCAsyncResponseStreamWriter<ChatMessage>]()
    func addResponseStream(responseStream: GRPCAsyncResponseStreamWriter<ChatMessage>) {
        responseStreams.append(responseStream)
    }
    
    func broadcastResponse(response: ChatMessage) async {
        for stream in responseStreams {
            do {
                try await stream.send(response)
            } catch {
                print("Message stream failed: \(error)")
            }
        }
    }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
final class ChatMessagesProvider: ChatRoomAsyncProvider {
    let streamActor = StreamActor()
    
    func connect(requestStream: GRPCAsyncRequestStream<ChatMessage>,
                 responseStream:GRPCAsyncResponseStreamWriter<ChatMessage>,
                 context: GRPCAsyncServerCallContext) async throws {
        await streamActor.addResponseStream(responseStream: responseStream)
        for try await request in requestStream {
            print("Message received \(request.textMessage)")
            await streamActor.broadcastResponse(response: request)
        }
    }
}

