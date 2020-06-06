struct Engine {
    static func run(fileName: String?,
                    path: String? = nil) {
        let tableOfContentPrinter = TableOfContentPrinter(rowFactory: TableRowLinkedFactory())
        let documentBodyPrinter = DocumentBodyPrinter()
        let generator = Generator(tableOfContentPrinter: tableOfContentPrinter,
                                  documentBodyPrinter: documentBodyPrinter)
        let documentShape = FileIORepository().fetchDocumentShape()
        let rootNode = generator.makeNodesLinkedList(from: documentShape)
        let head = Node(intent: "", title: "", content: "")
        head.nextSiblingNode = rootNode
        
        let tableOfContent = generator.printTitles(from: head, base: "")
        let content = generator.printContent(from: head, base: "")
        let document = Doc(tableOfContent: tableOfContent,
                           content: content)
        
        DocumentsOutputEncoder.encode(doc: document) { encodedContent in
            FilePrinter.printOutput(content: encodedContent,
                                    documentName: fileName,
                                    path: path)
        }
    }
}
