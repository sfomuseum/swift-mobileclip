import Foundation
import ArgumentParser

@main
struct Embeddings: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "embeddings",
    subcommands: [Text.self],
    defaultSubcommand: Text.self,
  )
}
