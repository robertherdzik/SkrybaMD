
public protocol OutputPrinting {
    static func printOutput(content: String, documentName: String?)
}

public struct ConsolePrinter: OutputPrinting {
    
    public static func printOutput(content: String, documentName: String? = nil) {
        print(content)
    }
}

public struct FilePrinter: OutputPrinting {
    static private let fileRepository = FileIORepository()
    
    public  static func printOutput(content: String, documentName: String?) {
        fileRepository.saveDocumentationOutputFile(with: content, documentName: documentName)
    }
}
