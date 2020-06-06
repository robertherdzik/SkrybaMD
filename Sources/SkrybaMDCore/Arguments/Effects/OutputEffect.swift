struct OutputEffect: ActionEffectable {
    private let engine = Engine.self
    
    func run(value: String?) {
        guard let value = value else {
            makeError()
            return
        }
        
        let elements = value.split(separator: "/")
        let fileName = elements.last!
        let path = elements.dropLast().joined(separator: "/")
        
        engine.run(fileName: String(fileName),
                   path: path)
    }
    
    private func makeError() {
        let instruction = """
        😬 relative path to the output file is missing...
        """
        print(instruction)
    }
}
