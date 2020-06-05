
public protocol OutputPrinting {
    static func printOutput(content: String,
                            documentName: String?,
                            path: String?)
}

public struct ConsolePrinter: OutputPrinting {
    
    public static func printOutput(content: String,
                                   documentName: String?,
                                   path: String?) {
        print(content)
    }
}

public struct FilePrinter: OutputPrinting {
    static private let fileRepository = FileIORepository()
    
    public  static func printOutput(content: String,
                                    documentName: String?,
                                    path: String?) {
        fileRepository.saveDocumentationOutputFile(with: content,
                                                   documentName: documentName,
                                                   path: path)
    }
}
