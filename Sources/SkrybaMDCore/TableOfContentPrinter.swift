
public struct TableOfContentPrinter: TableOfContentPrinting {
    private var rowFactory: TableRowFactoring
    
    public init(rowFactory: TableRowFactoring) {
        self.rowFactory = rowFactory
    }
    
    public func print(from node: Node, base: String) -> String {
        if let innerNode = node.innerNode {
            return rowFactory.make(node: innerNode, base: base)
                + print(from: innerNode, base: base)
        }
        
        if let next = node.nextSiblingNode {
            return rowFactory.make(node: next, base: base)
                + print(from: next, base: base)
        }
        
        return ""
    }
}
