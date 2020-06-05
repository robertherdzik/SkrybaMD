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

struct InstallationEffect: ActionEffectable {
    func run(value: String?) {
        print("Installing script globally 🌍...")
        print("Now you can use script \(productName) from everywhere 🚀")
        print("Run \"\(productName) --help\" to get more info 🙇‍♂️")
        shell("cp", "-f", "./\(productName)", "/usr/local/bin/\(productName)")
    }
}

struct HelpEffect: ActionEffectable {
    func run(value: String?) {
        let instruction = """
        ⏬ To install globally run: ./\(productName) --install
        USAGE:
        📝 Run script and file name as a first parameter e.g.: >> $ ./\(productName) StyleGuide.md
        NOTE: If you don't specify output file name, script will use default one.
        """
        print(instruction)
    }
}

struct OutputEffect: ActionEffectable {
    func run(value: String?) {
        guard let value = value else { return }
        
        let elements = value.split(separator: "/")
        let fileName = elements.last!
        let path = elements.dropLast().joined(separator: "/")
            
        generate(fileName: String(fileName), path: path)
//        path: // _TODO [🌶]:)
    }
}


/// This effect is taking argument, and create output file according to this argument
/// NOTE: we assume that as a argument user will pass file name
struct UndefinedEffect: ActionEffectable {
    func run(value: String?) {
        generate(fileName: value)
    }
}

enum Argument {
    private enum Constant {
        static let install = "--install"
        static let help = "--help"
        static let helpShort = "-h"
        static let output = "--output"
        static let outputShort = "-o"
    }
    
    case installation
    case help
    case outputPath
    case undefined
    
    init(argument: String) {
        switch argument {
        case Constant.install:
            self = .installation
        case Constant.help,
             Constant.helpShort:
            self = .help
        case Constant.output, Constant.outputShort:
            self = .outputPath
        default:
            self = .undefined
        }
    }
    
    func effect() -> ActionEffectable? {
        switch self {
        case .installation:
            return InstallationEffect()
        case .help:
            return HelpEffect()
        case .outputPath:
            return OutputEffect()
        case .undefined:
            return UndefinedEffect()
        }
    }
}

let arguments = CommandLine.arguments
let productName = "SkrybaMD"

// >> $ ./SkrybaMD StyleGuide.md
func runScript() {
    let argument = arguments[1]
    let value = arguments[2]
    
    Argument(argument: argument)
        .effect()?
        .run(value: value)
}

runScript()
