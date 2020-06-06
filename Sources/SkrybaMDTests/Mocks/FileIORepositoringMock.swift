import SkrybaMDCore

final class FileIORepositoringMock: FileIORepositoring {
    var fetchDocumentShapeReturn = ""
    var fetchFileContentReturn = ""
    var saveDocumentationOutputFileDocumentPath: String?
   
    var saveDocumentationOutputFileContent: String?
    var saveDocumentationOutputFileDocumentName: String?
    
    var createEmptyFileFileName: String?
    
    func fetchDocumentShape() -> String {
        fetchDocumentShapeReturn
    }
    
    func fetchFileContent(from fileName: String) -> String? {
        fetchFileContentReturn
    }
    
    // _TODO [🌶]: unit tests
    func saveDocumentationOutputFile(with content: String, documentName: String?, path: String?) {
        saveDocumentationOutputFileContent = content
        saveDocumentationOutputFileDocumentName = documentName
        saveDocumentationOutputFileDocumentPath = path
    }
    
    func createEmptyFile(with fileName: String?) {
        createEmptyFileFileName = fileName
    }
}
