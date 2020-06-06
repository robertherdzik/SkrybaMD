struct GenerateFileWithoutPathEffect: ActionEffectable {
    private let engine = Engine.self
    
    func run(value: String?) {
        engine.run(fileName: value)
    }
}
