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

protocol ActionEffectable {
    func run()
}

struct InstallationEffect: ActionEffectable {
    func run() {
        print("Installing script globally 🌍...")
        print("Now you can use script \(productName) from everywhere 🚀")
        print("Run \"\(productName) --help\" to get more info 🙇‍♂️")
        shell("cp", "-f", "./\(productName)", "/usr/local/bin/\(productName)")
    }
}

struct HelpEffect: ActionEffectable {
    func run() {
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
    private let path: String
    
    init(path: String) {
        self.path = path
    }
    
    func run() {
        let instruction = """
                   // _TODO [🌶]:
                   """
        print(path)
    }
}


/// This effect is taking argument, and create output file according to this argument
/// NOTE: we assume that as a argument user will pass file name
struct UndefinedEffect: ActionEffectable {
    private let argument: String
    
    init(argument: String) {
        self.argument = argument
    }
    
    func run() {
        generate(fileName: argument)
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
    case outputPath(_ path: String)
    case undefined(_ argument: String) // _TODO [🌶]: maybe is not good idea to pass raw argumnt and handle it as a file name
    
    init(argument: String) {
        switch argument {
        case Constant.install:
            self = .installation
        case Constant.help,
             Constant.helpShort:
            self = .help
        case Constant.output:
            let path = argument.replacingOccurrences(of: Constant.output + " ", with: "")
            self = .outputPath(path)
        case Constant.outputShort:
            let path = argument.replacingOccurrences(of: Constant.outputShort + " ", with: "")
            self = .outputPath(path)
        default:
            self = .undefined(argument)
        }
    }
    
    func effect() -> ActionEffectable? {
        switch self {
        case .installation:
            return InstallationEffect()
        case .help:
            return HelpEffect()
        case let .outputPath(path):
           return OutputEffect(path: path)
        case let .undefined(argument):
            return UndefinedEffect(argument: argument)
        }
    }
}

let arguments = CommandLine.arguments
let productName = "SkrybaMD"

// >> $ ./SkrybaMD StyleGuide.md
func runScript() {
    guard let argumet = arguments.first else {
        generate(fileName: nil)
        return
    }
    
    Argument(argument: argumet)
        .effect()?
        .run()
}

runScript()
