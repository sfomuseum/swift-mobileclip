import Foundation
import ArgumentParser

@main
struct Server: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "server",
    subcommands: [gRPCServer.self ],
    defaultSubcommand: gRPCServer.self,
  )
}
