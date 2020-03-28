import SkrybaMDCore

final class TableOfContentPrintingMock: TableOfContentPrinting {
    var printReturn = ""
  
    func print(from node: Node, base: String) -> String {
        printReturn
    }
}
