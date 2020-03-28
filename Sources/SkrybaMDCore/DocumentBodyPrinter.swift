
public struct DocumentBodyPrinter: DocumentBodyPrinting {
    private let intentFactory = IntentFactory()
    
    public init() { }
    
    public func print(from node: Node, base: String) -> String {
        func templateFactory(node: Node,
                             stertItem: String,
                             isInnerNode: Bool) -> String {
            Constant.newLine
                + generateIntentForContent(baseOn: node.intentCount(), isInnerNode: isInnerNode)
                + stertItem
                + Constant.space
                + node.index
                + Constant.space
                + node.title
                + Constant.newLine
                + node.content
                + print(from: node, base: base)
        }
        
        if let innerNode = node.innerNode {
            let stertItem = innerNode.intentCount() == 2 ? MDSign.Header.small : MDSign.List.sign
            
            return templateFactory(node: innerNode,
                                   stertItem: stertItem,
                                   isInnerNode: true)
        }
        
        if let next = node.nextSiblingNode {
            let isRootOfNodes = next.intentCount() == 1
            let stertItem = isRootOfNodes ? MDSign.Header.big : MDSign.List.sign
            
            return templateFactory(node: next,
                                   stertItem: stertItem,
                                   isInnerNode: !isRootOfNodes)
        }
        
        return ""
    }
    
    private func generateIntentForContent(baseOn index: Int, isInnerNode: Bool) -> String {
        // We don't want to have intent, aligment with old manual Documentation look and feel
        guard index < 2 else { return "" }
        // MD parsers are not treated well \t intent so we need to adjust by -1 space intention topics to make them work 💩
        let additionalIntent = isInnerNode ? 1 : 0
        
        return intentFactory.make(baseOn: index - additionalIntent)
    }
}
