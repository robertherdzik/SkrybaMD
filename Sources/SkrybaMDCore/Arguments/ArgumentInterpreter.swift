import ArgumentParser

public struct SkrybaMD: ParsableCommand {
    public static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "SkrybaMD",
            abstract: "A Swifty Markdown generator",
            discussion: "NOTE: If no parameter specified, .md file with default name at current directory is going to be generated.",
            subcommands: [
                Output.self,
                OutputNotProvided.self
            ],
            defaultSubcommand: OutputNotProvided.self
        )
    }
    
    public init() { }
}

extension SkrybaMD {
    struct Output: ParsableCommand {
        static let configuration = CommandConfiguration(commandName: "output",
                                                        abstract: "Generate md file using provided in the parameter output. NOTE: use -h for more info.")
        
        @Option(
            help: ArgumentHelp(
                "Provide path for generated .md file output. e.g.: ../MyFolder/OutputFileName.md")
        )
        private var path: String
        
        public init() { }
        
        public func run() throws {
            OutputEffect()
                .run(value: path)
        }
    }

    struct OutputNotProvided: ParsableCommand {
        static let configuration = CommandConfiguration(commandName: "generate",
                                                        abstract: "Generate md file in current directory specifying file name, or using default one. NOTE: use -h for more info.")
        
        @Option(
            help: ArgumentHelp(
                "Specify ouput file name (NOTE: without .md extension), if not specified, use default name.")
        )
        private var filename: String?
        
        public init() { }
        
        public func run() throws {
            GenerateFileWithoutPathEffect()
                .run(value: filename)
        }
    }
}
