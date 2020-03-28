import SkrybaMDCore

final class FileIORepositoringMock: FileIORepositoring {
    var fetchDocumentShapeReturn = ""
    var fetchFileContentReturn = ""
   
    var saveDocumentationOutputFileContent: String?
    var saveDocumentationOutputFileDocumentName: String?
    
    var createEmptyFileFileName: String?
    
    func fetchDocumentShape() -> String {
        fetchDocumentShapeReturn
    }
    
    func fetchFileContent(from fileName: String) -> String? {
        fetchFileContentReturn
    }
    
    func saveDocumentationOutputFile(with content: String, documentName: String?) {
        saveDocumentationOutputFileContent = content
        saveDocumentationOutputFileDocumentName = documentName
    }
    
    func createEmptyFile(with fileName: String?) {
        createEmptyFileFileName = fileName
    }
}
