
/// Struct print table plain content option: `- 1.0 General`
public struct TableRowPlainFactory: TableRowFactoring {
    private let intentFactory = IntentFactory()
    
    public init() { }
    
    public func make(node: Node, base: String) -> String {
        Constant.newLine
            + intentFactory.make(baseOn: node.intentCount())
            + Constant.intent
            + Constant.space
            + node.index
            + Constant.space
            + node.title
    }
}
