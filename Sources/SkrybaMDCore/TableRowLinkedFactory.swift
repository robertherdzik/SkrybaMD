
/// Struct print table content with link option: `- [1.0 General](#10-general)`
public struct TableRowLinkedFactory: TableRowFactoring {
    private struct ConstantPrivate {
        static let squareBracketOpen = "["
        static let squareBracketClose = "]"
        static let linkOpen = "(#"
        static let linkClose = ")"
        static let dash = "-"
        static let digitSeparator = "."
    }
    
    private let intentFactory = IntentFactory()
    
    public init() { }
    
    public func make(node: Node, base: String) -> String {
        Constant.newLine
            + intentFactory.make(baseOn: node.intentCount())
            + Constant.intent
            + Constant.space
            + ConstantPrivate.squareBracketOpen
            + node.index
            + Constant.space
            + node.title
            + ConstantPrivate.squareBracketClose
            + ConstantPrivate.linkOpen
            // We need to convert 2.0 to 20 (removing dots)
            + node.index.replacingOccurrences(of: ConstantPrivate.digitSeparator, with: "")
            + ConstantPrivate.dash
            + node.title.replacingOccurrences(of: " ", with: ConstantPrivate.dash).lowercased()
            + ConstantPrivate.linkClose
    }
}
