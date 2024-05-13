import ArgumentParser
import GRPC
import NIOCore
import NIOPosix
import SwiftProtobuf

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
@main
struct iOSKonfChatServer: AsyncParsableCommand {
  @Option(help: "The port to listen on for new connections")
  var port = 1234

  func run() async throws {
    let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    defer {
      try! group.syncShutdownGracefully()
    }

    // Start the server and print its address once it has started.
    let server = try await Server.insecure(group: group)
      .withServiceProviders([ChatMessagesProvider()])
      .bind(host: "localhost", port: self.port)
      .get()

    print("server started on port \(server.channel.localAddress!.port!)")

    // Wait on the server's `onClose` future to stop the program from exiting.
    try await server.onClose.get()
  }
}
