//
//  main.swift
//  MDDocGen
//
//  Created by Robert Herdzik on 15/02/2020.
//  Copyright © 2020 Robert Herdzik. All rights reserved.
//

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
    func saveDocumentationOutputFile(with content: String)
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
    
    func saveDocumentationOutputFile(with content: String) {
        let fileName = "Documentation.md"
        let path = fileManager.currentDirectoryPath + "/" + fileName
        
        printProcessLogs(with: "Documentation generated and saved at: \(Constant.newLine)🦠 ➡️ \(path)")
        
        try! content.write(toFile: path, atomically: true, encoding: .utf8)
    }
}

struct Generator {
    private let fileRepository: FileIORepositoring
    
    init(fileRepository: FileIORepositoring = FileIORepository()) {
        self.fileRepository = fileRepository
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
        func templateFactory(node: Node, base: String) -> String {
            Constant.newLine
                + generateIntent(baseOn: node.intentCount())
                + Constant.intent
                + Constant.space
                + node.index
                + Constant.space
                + node.title
                + printTitles(from: node, base: base)
        }
    
        if let innerNode = node.innerNode {
            return templateFactory(node: innerNode, base: base)
        }
        
        if let next = node.nextSiblingNode {
            return templateFactory(node: next, base: base)
        }
        
        return ""
    }
    
    func printContent(from node: Node, base: String) -> String {
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
            + printContent(from: node, base: base)
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
    
    private func generateIntent(baseOn index: Int) -> String {
        String(repeating: Constant.tab, count: index - 1)
    }
    
    private func generateIntentForContent(baseOn index: Int, isInnerNode: Bool) -> String {
        // We don't want to have intent, aligment with old manual Documentation look and feel
        guard index < 2 else { return "" }
        // MD parsers are not treated well \t intent so we need to adjust by -1 space intention topics to make them work 💩
        let additionalIntent = isInnerNode ? 1 : 0
        
        return generateIntent(baseOn: index - additionalIntent)
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

struct DocumentPrinter {
    
    static func print(doc: Doc, printerOutput: (String) -> Void) {
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
    static func printOutput(content: String)
}

struct ConsolePrinter: OutputPrinting {
    
    static func printOutput(content: String) {
        print(content)
    }
}

struct FilePrinter: OutputPrinting {
    static private let fileRepository = FileIORepository()
    
    static func printOutput(content: String) {
        fileRepository.saveDocumentationOutputFile(with: content)
    }
}

//------------------------------------------------

let generator = Generator()
let documentShape = FileIORepository().fetchDocumentShape()
let rootNode = generator.makeNodesLinkedList(from: documentShape)
let head = Node(intent: "", title: "", content: "")
head.nextSiblingNode = rootNode

let tableOfContent = generator.printTitles(from: head, base: "")
let content = generator.printContent(from: head, base: "")
let document = Doc(tableOfContent: tableOfContent,
                   content: content)

DocumentPrinter.print(doc: document,
                      printerOutput: FilePrinter.printOutput)


