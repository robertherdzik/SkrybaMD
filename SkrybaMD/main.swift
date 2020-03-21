//
//  main.swift
//  SkrybaMD
//
//  Created by Robert Herdzik on 15/02/2020.
//  Copyright © 2020 Robert Herdzik. All rights reserved.
//

@discardableResult
func shell(_ args: String...) -> Int32 {
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = args
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}

import Foundation

enum Constant {
    static let newLine = "\n"
    static let separator = "||"
    static let intent = "-"
    static let space = " "
    static let tab = "\t"
}


final class Node {
    let intent: String
    let title: String
    var content: String
    var index: String!
    var prevSiblingNode: Node?
    var innerNode: Node?
    var nextSiblingNode: Node?
    
    init(intent: String,
         title: String,
         content: String) {
        self.intent = intent
        self.title = title
        self.content = content
    }
    
    func intentCount() -> Int {
        intent.count
    }
}

struct Doc {
    let tableOfContent: String
    let content: String
}

protocol FileIORepositoring {
    func fetchDocumentShape() -> String
    func fetchFileContent(from fileName: String) -> String
    func saveDocumentationOutputFile(with content: String, documentName: String?)
}

struct FileIORepository: FileIORepositoring {
    private let fileManager = FileManager.default
    
    func fetchDocumentShape() -> String {
        let docShape = fetchFileContent(from: "doc_shape.txt")
        
        printProcessLogs(with: "Processing following doc shape: \(Constant.newLine)\(Constant.newLine)\(docShape)")
        
        return docShape
    }
    
    func fetchFileContent(from fileName: String) -> String {
        let path = fileManager.currentDirectoryPath + "/" + fileName
        // _TODO [🌶]: add exception catch if there is no file, and remove force unwrap
        return try! String(contentsOfFile: path, encoding: String.Encoding.utf8)
    }
    
    func saveDocumentationOutputFile(with content: String, documentName: String?) {
        let fileName = documentName ?? "StyleGuide"
        let path = fileManager.currentDirectoryPath + "/" + fileName + ".md"
        
        printProcessLogs(with: "Documentation generated and saved at: \(Constant.newLine)🦠 ➡️ \(path)")
        
        try! content.write(toFile: path, atomically: true, encoding: .utf8)
    }
}

struct IntentFactory {
    func make(baseOn index: Int) -> String {
        String(repeating: Constant.tab, count: index - 1)
    }
}

protocol TableOfContentPrinting {
    func print(from node: Node, base: String) -> String
}

protocol TableRowFactoring {
    func make(node: Node, base: String) -> String
}

/// Struct print table plain content option: `- 1.0 General`
struct TableRowPlainFactory: TableRowFactoring {
    let intentFactory = IntentFactory()
    
    func make(node: Node, base: String) -> String {
        Constant.newLine
            + intentFactory.make(baseOn: node.intentCount())
            + Constant.intent
            + Constant.space
            + node.index
            + Constant.space
            + node.title
    }
}

/// Struct print table content with link option: `- [1.0 General](#10-general)`
struct TableRowLinkedFactory: TableRowFactoring {
    private struct ConstantPrivate {
        static let squareBracketOpen = "["
        static let squareBracketClose = "]"
        static let linkOpen = "(#"
        static let linkClose = ")"
        static let dash = "-"
        static let digitSeparator = "."
    }
    
    let intentFactory = IntentFactory()
    
    func make(node: Node, base: String) -> String {
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

struct TableOfContentPrinter: TableOfContentPrinting {
    var rowFactory: TableRowFactoring
    
    init(rowFactory: TableRowFactoring) {
        self.rowFactory = rowFactory
    }
    
    func print(from node: Node, base: String) -> String {
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


protocol DocumentBodyPrinting {
    func print(from node: Node, base: String) -> String
}

struct DocumentBodyPrinter: DocumentBodyPrinting {
    let intentFactory = IntentFactory()
    
    func print(from node: Node, base: String) -> String {
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

struct Generator {
    private let fileRepository: FileIORepositoring
    private let tableOfContentPrinter: TableOfContentPrinting
    private let documentBodyPrinter: DocumentBodyPrinting
    
    init(fileRepository: FileIORepositoring = FileIORepository(),
         tableOfContentPrinter: TableOfContentPrinting,
         documentBodyPrinter: DocumentBodyPrinting) {
        self.fileRepository = fileRepository
        self.tableOfContentPrinter = tableOfContentPrinter
        self.documentBodyPrinter = documentBodyPrinter
    }
    
    func makeNodesLinkedList(from text: String) -> Node {
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
    
    func printTitles(from node: Node, base: String) -> String {
        tableOfContentPrinter.print(from: node, base: base)
    }
    
    func printContent(from node: Node, base: String) -> String {
        documentBodyPrinter.print(from: node, base: base)
    }
    
    private func generateNode(from row: String.SubSequence) -> Node {
        let rowElements = row.components(separatedBy: Constant.separator)
        let intent = rowElements.first!.trimmingCharacters(in: .whitespacesAndNewlines)
        let title = rowElements[1].trimmingCharacters(in: .whitespacesAndNewlines)
        
        var contentFileValue: String!
        if let contentFile = rowElements.last?.trimmingCharacters(in: .whitespacesAndNewlines) {
            contentFileValue = fileRepository.fetchFileContent(from: contentFile)
        }
        
        return Node(intent: intent,
                    title: title,
                    content: contentFileValue)
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

//------------------------------------------------

struct MDSign {
    
    struct Header {
        static let big = "## "
        static let small = "### "
    }
    
    struct List {
        static let sign = "#### "
    }
}

func printProcessLogs(with content: String) {
    print("\(Constant.newLine)✅ " + content)
}

struct DocumentsOutputEncoder {
    
    static func encode(doc: Doc, printerOutput: (String) -> Void) {
        let documentHeaderTitle = MDSign.Header.big
            + "Table Of Content"
        
        let result = documentHeaderTitle
            + Constant.newLine
            + doc.tableOfContent
            + Constant.newLine
            + doc.content
        
        printerOutput(result)
    }
}

//------------------------------------------------

protocol OutputPrinting {
    static func printOutput(content: String, documentName: String?)
}

struct ConsolePrinter: OutputPrinting {
    
    static func printOutput(content: String, documentName: String? = nil) {
        print(content)
    }
}

struct FilePrinter: OutputPrinting {
    static private let fileRepository = FileIORepository()
    
    static func printOutput(content: String, documentName: String?) {
        fileRepository.saveDocumentationOutputFile(with: content, documentName: documentName)
    }
}

//------------------------------------------------

func generate(fileName: String?) {
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
        FilePrinter.printOutput(content: encodedContent, documentName: fileName)
    }
}

//------------------------------------------------

let arguments = CommandLine.arguments
// _TODO [🌶]: use product name instead of hardcoded string
let productName = "SkrybaMD"

// >> $ ./SkrybaMD StyleGuide.md
if arguments.count > 1 {
    let fileName = arguments[1]
    
    switch fileName {
    case "--install":
        print("Installing script globally 🌍...")
        print("Now you can use script \(productName) from everywhere 🚀")
        print("Run \"\(productName) --help\" to get more info 🙇‍♂️")
        shell("cp", "-f", "./\(productName)", "/usr/local/bin/\(productName)")
    case "--help", "-h":
        let help = """
        ⏬ To install globally run: ./\(productName) --install
        USAGE:
        📝 Run script and file name as a first parameter e.g.: >> $ ./\(productName) StyleGuide.md
        NOTE: If you don't specify output file name, script will use default one.
        """
        print(help)
    default:
        generate(fileName: fileName)
    }
    
} else {
    generate(fileName: nil)
}

