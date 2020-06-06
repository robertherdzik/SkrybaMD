enum Argument {
    private enum Constant {
        static let help = "--help"
        static let helpShort = "-h"
        static let output = "--output"
        static let outputShort = "-o"
    }
    
    case help
    case outputPath
    case undefined(_ argument: String)
    
    init(argument: String) {
        switch argument {
        case Constant.help,
             Constant.helpShort:
            self = .help
        case Constant.output, Constant.outputShort:
            self = .outputPath
        default:
            self = .undefined(argument)
        }
    }
    
    func effect() -> ActionEffectable? {
        switch self {
        case .help:
            return HelpEffect()
        case .outputPath:
            return OutputEffect()
        case let .undefined(argument):
            return UndefinedEffect(argument: argument)
        }
    }
}
