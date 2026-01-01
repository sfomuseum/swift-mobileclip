import Foundation
import ArgumentParser

@main
struct gRPCServer: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "server",
    subcommands: [Serve.self, Image.self, Text.self ],
    defaultSubcommand: Serve.self,
  )
}
