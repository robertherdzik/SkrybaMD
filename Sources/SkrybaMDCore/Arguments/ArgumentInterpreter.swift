public struct ArgumentInterpreter {
    public static func run(with arguments: [String]) {
        switch arguments.count {
        case 1:
            GenerateFileWithoutPathEffect()
                .run(value: nil)
        case 2:
            let argument = arguments[1]
            let value = arguments[safe: 2]
            
            Argument(argument: argument)
                .effect()?
                .run(value: value)
        case 3:
            let argument = arguments[1]
            let value = arguments[safe: 2]
            
            Argument(argument: argument)
                .effect()?
                .run(value: value)
        default:
            break
        }
    }
}
