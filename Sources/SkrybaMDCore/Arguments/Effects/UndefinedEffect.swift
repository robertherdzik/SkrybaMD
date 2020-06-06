struct UndefinedEffect: ActionEffectable {
    private let argument: String
    init(argument: String) {
        self.argument = argument
    }
    
    func run(value: String?) {
        GenerateFileWithoutPathEffect()
            .run(value: argument)
    }
}
