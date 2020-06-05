public protocol FileIORepositoring {
    func fetchDocumentShape() -> String
    func fetchFileContent(from fileName: String) -> String?
    func saveDocumentationOutputFile(with content: String,
                                     documentName: String?,
                                     path: String?)
    func createEmptyFile(with fileName: String?)
}
