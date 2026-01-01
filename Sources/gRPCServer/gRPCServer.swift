import Foundation
import ArgumentParser

@main
struct gRPCServer: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "server",
    subcommands: [Serve.self, Client.self ],
    defaultSubcommand: Serve.self,
  )
}
