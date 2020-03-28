
public final class Node {
    public let intent: String
    public let title: String
    public var content: String
    public var index: String!
    public var prevSiblingNode: Node?
    public var innerNode: Node?
    public var nextSiblingNode: Node?
    
    public init(intent: String,
         title: String,
         content: String) {
        self.intent = intent
        self.title = title
        self.content = content
    }
    
    public func intentCount() -> Int {
        intent.count
    }
}
