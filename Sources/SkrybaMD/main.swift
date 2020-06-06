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

func generate(fileName: String?,
              path: String? = nil) {
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
        FilePrinter.printOutput(content: encodedContent,
                                documentName: fileName,
                                path: path)
    }
}

//------------------------------------------------

protocol ActionEffectable {
    func run(value: String?)
}

struct HelpEffect: ActionEffectable {
    func run(value: String?) {
        let instruction = """
        ------------------------------------------------
        
        USAGE:
        📝 Run script and file name as a first parameter e.g.:
        
        >> $ \(productName) StyleGuideDoc
        NOTE: If you don't specify output file name, script will use default one.
        
        [--output | -o] - Define output relative path, with file name
        >> $ \(productName) -o /MyDocumentations/StyleGuideDoc
        
        [--help | -h] - See help
        >> $ \(productName) -h

        ------------------------------------------------
        
        See more details here: https://github.com/robertherdzik/SkrybaMD
        """
        print(instruction)
    }
}

struct OutputEffect: ActionEffectable {
    func run(value: String?) {
        guard let value = value else {
            makeError()
            return
        }
        
        let elements = value.split(separator: "/")
        let fileName = elements.last!
        let path = elements.dropLast().joined(separator: "/")
            
        generate(fileName: String(fileName), path: path)
    }
    
    private func makeError() {
        let instruction = """
        😬 relative path to the output file is missing...
        """
        print(instruction)
    }
}

struct GenerateFileWithoutPathEffect: ActionEffectable {
    func run(value: String?) {
        generate(fileName: value)
    }
}

struct UndefinedEffect: ActionEffectable {
    private let argument: String
    init(argument: String) {
        self.argument = argument
    }
    
    func run(value: String?) {
        GenerateFileWithoutPathEffect()
            .run(value: argument)
    }
}

enum Argument {
    private enum Constant {
        static let help = "--help"
        static let helpShort = "-h"
        static let output = "--output"
        static let outputShort = "-o"
    }
    
    case help
    case outputPath
    case undefined(_ argument: String)
    
    init(argument: String) {
        switch argument {
        case Constant.help,
             Constant.helpShort:
            self = .help
        case Constant.output, Constant.outputShort:
            self = .outputPath
        default:
            self = .undefined(argument)
        }
    }
    
    func effect() -> ActionEffectable? {
        switch self {
        case .help:
            return HelpEffect()
        case .outputPath:
            return OutputEffect()
        case let .undefined(argument):
            return UndefinedEffect(argument: argument)
        }
    }
}

let arguments = CommandLine.arguments
let productName = "SkrybaMD"

// >> $ ./SkrybaMD StyleGuide.md
func runScript() {
    switch arguments.count {
    case 1:
        GenerateFileWithoutPathEffect()
            .run(value: nil)
    case 2:
        let argument = arguments[1]
        let value = arguments[safe: 2]
        
        Argument(argument: argument)
            .effect()?
            .run(value: value)
    case 3:
        let argument = arguments[1]
        let value = arguments[safe: 2]
        
        Argument(argument: argument)
            .effect()?
            .run(value: value)
    default:
        break
    }
    
}

runScript()

// _TODO [🌶]: move to helpers
extension Array {
    public subscript(safe x: Int) -> Element? {
        if self.count > x {
            return self[x]
        }
        
        return nil
    }
}
