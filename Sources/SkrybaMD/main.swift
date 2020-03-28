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
import SkrybaMDCore

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

