//
//  main.swift
//  MDDocGen
//
//  Created by Robert Herdzik on 15/02/2020.
//  Copyright © 2020 Robert Herdzik. All rights reserved.
//

import Foundation

let newLine = "\n"
let separator = "||"
let intent = "-"
let space = " "
let tab = "\t"

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

func fetchDocumentShape() -> String {
    // Debug Shape
//    let docShape = """
//    i || General || general.md
//    i || Architecture || architecture_config.md
//    ii || Our Approach || our_approach.md
//    iii || Our Approach Description || our_approach_description.md
//    iii || Our Approach Description || our_approach_description.md
//    iiii || Our Approach Description || our_approach_description.md
//    ii || Why This One || why_this_one.md
//    i || CI and Rest || ci_and_rest.md
//    """
    
    let docShape = fetchFileContent(from: "doc_shape.txt")

    printProcessLogs(with: "Processing following doc shape: \(newLine)\(newLine)\(docShape)")
    
    return docShape
}

func fetchFileContent(from fileName: String) -> String {
    let path = FileManager.default.currentDirectoryPath + "/" + fileName
    // _TODO [🌶]: add exception catch if there is no file, and remove force unwrap
    return try! String(contentsOfFile: path, encoding: String.Encoding.utf8)

//    return " ❤️ "
}

func saveDocumentationOutputFile(with content: String) {
    let fileManager = FileManager.default
    let fileName = "Documentation.md"
    let path = fileManager.currentDirectoryPath + "/" + fileName
    
    printProcessLogs(with: "Documentation generated and saved at: \(newLine)🦠 ➡️ \(path)")
    
    try! content.write(toFile: path, atomically: true, encoding: .utf8)
//    fileManager.createFile(atPath: path, contents: nil, attributes: nil)
}

func generateNode(from row: String.SubSequence) -> Node {
    let rowElements = row.components(separatedBy: separator)
    let intent = rowElements.first!.trimmingCharacters(in: .whitespacesAndNewlines)
    let title = rowElements[1].trimmingCharacters(in: .whitespacesAndNewlines)
    
    var contentFileValue: String!
    if let contentFile = rowElements.last?.trimmingCharacters(in: .whitespacesAndNewlines) {
        contentFileValue = fetchFileContent(from: contentFile)
    }
    
    return Node(intent: intent,
                title: title,
                content: contentFileValue)
}

func getClosestPrevSiblingNode(from node: Node?, with intent: Int) -> Node? {
    if let prevSiblingNode = node?.prevSiblingNode {
        if intent == prevSiblingNode.intent.count {
            return prevSiblingNode
        } else {
            return getClosestPrevSiblingNode(from: prevSiblingNode, with: intent)
        }
    }
    
    return nil
}

func makeFlatNodes(from imput: String) -> [Node] {
    let topicsArr = imput.split(separator: String.Element(newLine))
    
    return topicsArr.map { generateNode(from: $0) }
}

func createIndex(from lookupDict: [String: Int]) -> String {
    let sortedLookup = lookupDict.map { (key: $0, value: $1) }.sorted { $0.key.count < $1.key.count }
    
    var result = ""
    for item in sortedLookup {
        result += "\(item.value)."
    }
    
    return result + "0"
}

func numerate(input: String) -> [Node] {
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
    
    if let innerNode = node.innerNode {
        return newLine
            + generateIntent(baseOn: innerNode.intentCount())
            + intent
            + space
            + innerNode.index
            + space
            + innerNode.title
            + printTitles(from: innerNode, base: base)
    }
    
    if let next = node.nextSiblingNode {
        return newLine
            + generateIntent(baseOn: next.intentCount())
            + intent
            + space
            + next.index
            + space
            + next.title
            + printTitles(from: next, base: base)
    }
    
    return ""
}

func generateIntent(baseOn index: Int) -> String {
    String(repeating: tab, count: index - 1)
}

func generateIntentForContent(baseOn index: Int, isInnerNode: Bool) -> String {
    // We don't want to have intent, aligment with old manual Documentation look and feel
    guard index < 2 else { return "" }
    // MD parsers are not treated well \t intent so we need to adjust by -1 space intention topics to make them work 💩
    let additionalIntent = isInnerNode ? 1 : 0
    
    return generateIntent(baseOn: index - additionalIntent)
}

struct MDSign {
    
    struct Header {
        static let big = "## "
        static let small = "### "
    }
    
    struct List {
        static let sign = "#### "
    }
}

func printContent(from node: Node, base: String) -> String {
    
    if let innerNode = node.innerNode {
        let stertItem = innerNode.intentCount() == 2 ? MDSign.Header.small : MDSign.List.sign
        
        return newLine
            + generateIntentForContent(baseOn: innerNode.intentCount(), isInnerNode: true)
            + stertItem
            + space
            + innerNode.index
            + space
            + innerNode.title
            + newLine
            + innerNode.content
            + printContent(from: innerNode, base: base)
    }
    
    if let next = node.nextSiblingNode {
        let isRootOfNodes = next.intentCount() == 1
        let stertItem = isRootOfNodes ? MDSign.Header.big : MDSign.List.sign
        
        return newLine
            + generateIntentForContent(baseOn: next.intentCount(), isInnerNode: !isRootOfNodes)
            + stertItem
            + space
            + next.index
            + space
            + next.title
            + newLine
            + next.content
            + printContent(from: next, base: base)
    }
    
    return ""
}

func printProcessLogs(with content: String) {
    print("\(newLine)✅ " + content)
}

struct DocumentPrinter {
    
    static func print(doc: Doc, printerOutput: (String) -> Void) {
        let documentHeaderTitle = MDSign.Header.big
            + "Table Of Content"
       
        let result = documentHeaderTitle
            + newLine
            + doc.tableOfContent
            + newLine
            + doc.content
        
        printerOutput(result)
    }
}

protocol OutputPrinting {
    static func printOutput(content: String)
}

struct ConsolePrinter: OutputPrinting {
    
    static func printOutput(content: String) {
        print(content)
    }
}

struct FilePrinter: OutputPrinting {
   
    static func printOutput(content: String) {
        saveDocumentationOutputFile(with: content)
    }
}

let documentShape = fetchDocumentShape()
let rootNode = makeNodesLinkedList(from: documentShape)
let head = Node(intent: "", title: "", content: "")
head.nextSiblingNode = rootNode

let tableOfContent = printTitles(from: head, base: "")
let content = printContent(from: head, base: "")
let document = Doc(tableOfContent: tableOfContent,
                   content: content)

DocumentPrinter.print(doc: document,
                      printerOutput: FilePrinter.printOutput)
