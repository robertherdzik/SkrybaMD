import Foundation

public struct FileIORepository: FileIORepositoring {
    struct ConstantPrivate {
        static let mdFileExtension = ".md"
    }
    private let fileManager = FileManager.default
    
    public init () { }
    
    public func fetchDocumentShape() -> String {
        guard let docShape = fetchFileContent(from: "doc_shape.txt") else {
            fatalError("🧨 doc_shape.txt file not found!")
        }
        
        printProcessLogs(with: "Processing following doc shape: \(Constant.newLine)\(Constant.newLine)\(docShape)")
        
        return docShape
    }
    
    
    /// Metod return file content if exist
    /// - Parameter fileName: file name
    public func fetchFileContent(from fileName: String) -> String? {
        let path = fileManager.currentDirectoryPath + "/" + fileName
        
        return try? String(contentsOfFile: path, encoding: String.Encoding.utf8)
    }
    
    public func createEmptyFile(with fileName: String?) {
        guard let fileName = fileName,
            fileName.count > 0 else { return }
        
        let path = fileManager.currentDirectoryPath + "/" + fileName
        
        try! "".write(toFile: path, atomically: true, encoding: .utf8)
        printProcessLogs(with: Constant.tab + "🥳 empty \(fileName) created")
    }
    
    public func saveDocumentationOutputFile(with content: String, documentName: String?) {
        let fileName = documentName ?? "StyleGuide"
        let path = fileManager.currentDirectoryPath + "/" + fileName + ConstantPrivate.mdFileExtension
        
        printProcessLogs(with: "Documentation generated and saved at: \(Constant.newLine)🦠 ➡️ \(path)")
        
        try! content.write(toFile: path, atomically: true, encoding: .utf8)
    }
    
    private func printProcessLogs(with content: String) {
        print("\(Constant.newLine)✅ " + content)
    }
}


