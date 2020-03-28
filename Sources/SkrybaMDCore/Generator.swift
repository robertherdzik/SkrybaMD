public enum Constant {
    public static let newLine = "\n"
    public static let separator = "||"
    public static let intent = "-"
    public static let space = " "
    public static let tab = "\t"
}

public struct Generator {
    private let fileRepository: FileIORepositoring
    private let tableOfContentPrinter: TableOfContentPrinting
    private let documentBodyPrinter: DocumentBodyPrinting
    
    public init(fileRepository: FileIORepositoring = FileIORepository(),
                tableOfContentPrinter: TableOfContentPrinting,
                documentBodyPrinter: DocumentBodyPrinting) {
        self.fileRepository = fileRepository
        self.tableOfContentPrinter = tableOfContentPrinter
        self.documentBodyPrinter = documentBodyPrinter
    }
    
    public func makeNodesLinkedList(from text: String) -> Node {
        let nodesFlat = numerate(input: text)
        
        guard nodesFlat.count > 0 else { fatalError("Not enough elements") }
        
        let root: Node = nodesFlat.first!
        
        for i in 0...nodesFlat.count - 1 {
            let currentNode = nodesFlat[i]
            
            var nextNode: Node?
            if i < nodesFlat.count - 1 {
                nextNode = nodesFlat[i + 1]
            }
            
            var prevNode: Node?
            if i > 0 {
                prevNode = nodesFlat[i - 1]
            }
            currentNode.prevSiblingNode = prevNode
            if let nextNode = nextNode {
                if currentNode.intentCount() == 1 {
                    currentNode.nextSiblingNode = nextNode
                } else if nextNode.intentCount() <= currentNode.intentCount() {
                    currentNode.nextSiblingNode = nextNode
                }
                
                if nextNode.intentCount() == currentNode.intentCount() + 1 {
                    currentNode.innerNode = nextNode
                }
            }
        }
        
        return root
    }
    
    public func printTitles(from node: Node, base: String) -> String {
        tableOfContentPrinter.print(from: node, base: base)
    }
    
    public func printContent(from node: Node, base: String) -> String {
        documentBodyPrinter.print(from: node, base: base)
    }
    
    private func generateNode(from row: String.SubSequence) -> Node {
        let rowElements = row.components(separatedBy: Constant.separator)
        let intent = rowElements.first!.trimmingCharacters(in: .whitespacesAndNewlines)
        let title = rowElements[1].trimmingCharacters(in: .whitespacesAndNewlines)
        
        var contentFileValue: String?
        if let contentFile = rowElements.last?.trimmingCharacters(in: .whitespacesAndNewlines) {
            contentFileValue = fileRepository.fetchFileContent(from: contentFile)
            
            // _TODO [🌶]: this functionality of creating empty file should be in other place
            if contentFileValue == nil {
                fileRepository.createEmptyFile(with: contentFile)
            }
        }
        
        return Node(intent: intent,
                    title: title,
                    content: contentFileValue ?? "")
    }
    
    private func getClosestPrevSiblingNode(from node: Node?, with intent: Int) -> Node? {
        if let prevSiblingNode = node?.prevSiblingNode {
            if intent == prevSiblingNode.intent.count {
                return prevSiblingNode
            } else {
                return getClosestPrevSiblingNode(from: prevSiblingNode, with: intent)
            }
        }
        
        return nil
    }
    
    private func makeFlatNodes(from imput: String) -> [Node] {
        let topicsArr = imput.split(separator: String.Element(Constant.newLine))
        
        return topicsArr.map { generateNode(from: $0) }
    }
    
    private func createIndex(from lookupDict: [String: Int]) -> String {
        let sortedLookup = lookupDict.map { (key: $0, value: $1) }.sorted { $0.key.count < $1.key.count }
        
        var result = ""
        for item in sortedLookup {
            result += "\(item.value)."
        }
        
        return result + "0"
    }
    
    //       - [1. Code Formatting](#1-code-formatting)
    private func numerate(input: String) -> [Node] {
        let flatNodes = makeFlatNodes(from: input)
        
        var result = [Node]()
        var lookup: [String: Int] = [:]
        for i in 0..<(flatNodes.count) {
            let currentNode = flatNodes[i]
            var prevNode: Node?
            if i > 0 {
                prevNode = flatNodes[i - 1]
            }
            
            if let prevNoteIntentCount = prevNode?.intentCount() {
                if prevNoteIntentCount > currentNode.intentCount() {
                    let currentIntentCount = currentNode.intentCount()
                    
                    // reset lookup till current item intent count
                    var keysToReset = [String]()
                    for i in ((currentIntentCount + 1)...prevNoteIntentCount) {
                        lookup.forEach { key, value in
                            if key.count == i {
                                keysToReset.append(key)
                            }
                        }
                    }
                    
                    keysToReset.forEach { lookup.removeValue(forKey: $0) }
                }
            }
            
            if lookup[currentNode.intent] != nil {
                lookup[currentNode.intent]! += 1
            } else {
                lookup[currentNode.intent] = 1
            }
            
            currentNode.index = createIndex(from: lookup)
            
            
            
            
            
            result.append(currentNode)
        }
        
        return result
    }
}
