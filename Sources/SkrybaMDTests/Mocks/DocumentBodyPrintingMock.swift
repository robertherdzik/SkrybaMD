import SkrybaMDCore

final class DocumentBodyPrintingMock: DocumentBodyPrinting {
    var printReturn = ""
    
    func print(from node: Node, base: String) -> String {
        printReturn
    }
}
