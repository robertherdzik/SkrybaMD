import XCTest

import SkrybaMDCore

class GeneratorTests: XCTestCase {

    let fileRepositoryMock = FileIORepositoringMock()
    let tableOfContentPrinterMock = TableOfContentPrintingMock()
    let documentBodyPrinterMock = DocumentBodyPrintingMock()
    var sut: Generator!
    
    override func setUp() {
        super.setUp()
        
        sut = Generator(fileRepository: fileRepositoryMock,
                        tableOfContentPrinter: tableOfContentPrinterMock,
                        documentBodyPrinter: documentBodyPrinterMock)
    }
    
    func testMakeNodesLinkedList_WhenSingleNode_ShouldNotHaveParent() {
        let input = """
        i || General ||
        """
        
        let rootNode = sut.makeNodesLinkedList(from: input)
        
        XCTAssertNil(rootNode.prevSiblingNode)
    }
    
    func testMakeNodesLinkedList_WhenSingleNode_ShouldNotHaveNextSibling() {
        let input = """
        i || General ||
        """
        
        let rootNode = sut.makeNodesLinkedList(from: input)
        
        XCTAssertNil(rootNode.nextSiblingNode)
    }
    
    func testMakeNodesLinkedList_WhenSingleNode_ShouldNotHaveInnerNode() {
        let input = """
        i || General ||
        """
        
        let rootNode = sut.makeNodesLinkedList(from: input)
        
        XCTAssertNil(rootNode.innerNode)
    }
    
    func testMakeNodesLinkedList_WhenNodeHasSibling_ShouldNotHaveParent() {
        let input = """
        i || General ||
        i || General_Sibling ||
        """
        
        let rootNode = sut.makeNodesLinkedList(from: input)
        
        XCTAssertNil(rootNode.prevSiblingNode)
    }
    
    func testMakeNodesLinkedList_WhenNodeHasSibling_ShouldHaveNextSibling() {
        let input = """
        i || General ||
        i || General_Sibling ||
        """
        
        let rootNode = sut.makeNodesLinkedList(from: input)
        
        XCTAssertNotNil(rootNode.nextSiblingNode)
        XCTAssertEqual("General_Sibling", rootNode.nextSiblingNode?.title)
    }
    
    func testMakeNodesLinkedList_WhenNodeHasSibling_ShouldNotHaveInnerNode() {
        let input = """
        i || General ||
        i || General _ sibling ||
        """
        
        let rootNode = sut.makeNodesLinkedList(from: input)
        
        XCTAssertNil(rootNode.innerNode)
    }
    
    func testMakeNodesLinkedList_WhenNodeHasInnerNode_ShouldHaveInnerNode() {
        let input = """
        i || General ||
        ii || General _ inner ||
        """
        
        let rootNode = sut.makeNodesLinkedList(from: input)
        
        XCTAssertNotNil(rootNode.innerNode)
        XCTAssertEqual("General _ inner", rootNode.innerNode?.title)
    }
    
    func testMakeNodesLinkedList_WhenInnerNodeHasParent() {
        let input = """
        i || General ||
        ii || General _ inner |
        """
        
        let rootNode = sut.makeNodesLinkedList(from: input)
        
        let innerNode = rootNode.innerNode
        XCTAssertNotNil(innerNode?.prevSiblingNode)
        XCTAssertEqual("General", innerNode?.prevSiblingNode?.title)
        XCTAssertTrue(rootNode === innerNode?.prevSiblingNode)
    }
    
    func testMakeNodesLinkedList_WhenInnerNodeHasNextSibling() {
        let input = """
        i || General ||
        ii || General _ inner ||
        ii || General _ inner _ sibling ||
        """
        
        let rootNode = sut.makeNodesLinkedList(from: input)
        
        XCTAssertNotNil(rootNode.innerNode?.nextSiblingNode)
        XCTAssertEqual("General _ inner _ sibling", rootNode.innerNode?.nextSiblingNode?.title)
    }
    
    func testMakeNodesLinkedList_WhenSingleNode_ShouldHaveFirstIndex() {
        let input = """
        i || General ||
        """
        
        let rootNode = sut.makeNodesLinkedList(from: input)
        
        XCTAssertEqual("1.0", rootNode.index)
    }
    
    func testMakeNodesLinkedList_WhenTwoNodes_LastNodeShouldHaveSecondIndex() {
        let input = """
        i || General ||
        i || Second ||
        """
        
        let rootNode = sut.makeNodesLinkedList(from: input)
        
        XCTAssertEqual("2.0", rootNode.nextSiblingNode?.index)
    }
    
    func testMakeNodesLinkedList_WhenSingleInnerNode_InnerNodeShouldHaveMinorNumber() {
        let input = """
        i || General ||
        ii || Second inner ||
        """
        
        let rootNode = sut.makeNodesLinkedList(from: input)
        
        XCTAssertEqual("1.1.0", rootNode.nextSiblingNode?.index)
    }
    
    func testMakeNodesLinkedList_WhenTwoInnerNodes_SecondInnerNodeShouldHaveSecondMinorPositionNumber() {
        let input = """
        i || General ||
        ii || Second inner ||
        ii || Third inner  ||
        """
        
        let rootNode = sut.makeNodesLinkedList(from: input)
        
        XCTAssertEqual("1.2.0", rootNode.nextSiblingNode?.nextSiblingNode?.index)
    }
    
    func testMakeNodesLinkedList_WhenTwoSiblingNodesWithInnerNodes_SecondNodeShouldHaveMajorSecondNumber() {
        let input = """
        i || General ||
        ii || Second inner ||
        ii || Third inner  ||
        i || General  ||
        """
        
        let rootNode = sut.makeNodesLinkedList(from: input)
        
        XCTAssertEqual("2.0", rootNode.nextSiblingNode?.nextSiblingNode?.nextSiblingNode?.index)
    }
    
    func testMarkdownOutputSimple() {
        let documentShape = """
        i || General ||
        i || Architecture || architecture_config.md
        ii || Our Approach || our_approach.md
        i || CI and Rest || ci_and_rest.md
        i || Summary || summary.md

        """
        let fileRepositoryMock = FileIORepositoringMock()
        
        let tableOfContentPrinter = TableOfContentPrinter(rowFactory: TableRowLinkedFactory())
        let documentBodyPrinter = DocumentBodyPrinter()
        let sut = Generator(fileRepository: fileRepositoryMock,
                            tableOfContentPrinter: tableOfContentPrinter,
                            documentBodyPrinter: documentBodyPrinter)
        
        let rootNode = sut.makeNodesLinkedList(from: documentShape)
        let head = Node(intent: "", title: "", content: "")
        head.nextSiblingNode = rootNode

        let tableOfContent = sut.printTitles(from: head, base: "")
        let content = sut.printContent(from: head, base: "")
        let document = Doc(tableOfContent: tableOfContent,
                           content: content)
        
        let expectedDocumentShape = """

        ##  1.0 General

        ##  2.0 Architecture

        ###  2.1.0 Our Approach

        ##  3.0 CI and Rest

        ##  4.0 Summary

        """
        XCTAssertEqual(expectedDocumentShape, document.content)
    }
    
     func testMarkdownOutputComplex() {
            let documentShape = """
            i || General ||
            i || Architecture || architecture_config.md
            ii || Our Approach || our_approach.md
            iii || Our Approach || our_approach.md
            ii || CI and Rest || ci_and_rest.md
            i || Summary || summary.md
            """
            let fileRepositoryMock = FileIORepositoringMock()
            
            let tableOfContentPrinter = TableOfContentPrinter(rowFactory: TableRowLinkedFactory())
            let documentBodyPrinter = DocumentBodyPrinter()
            let sut = Generator(fileRepository: fileRepositoryMock,
                                tableOfContentPrinter: tableOfContentPrinter,
                                documentBodyPrinter: documentBodyPrinter)
            
            let rootNode = sut.makeNodesLinkedList(from: documentShape)
            let head = Node(intent: "", title: "", content: "")
            head.nextSiblingNode = rootNode

            let tableOfContent = sut.printTitles(from: head, base: "")
            let content = sut.printContent(from: head, base: "")
            let document = Doc(tableOfContent: tableOfContent,
                               content: content)
            
            let expectedDocumentShape = """
            
            ##  1.0 General

            ##  2.0 Architecture

            ###  2.1.0 Our Approach

            ####  2.1.1.0 Our Approach

            ###  2.2.0 CI and Rest

            ##  3.0 Summary

            """
        
            XCTAssertEqual(expectedDocumentShape, document.content)
        }
    
    func testMarkdownOutputCliff() {
           let documentShape = """
           i || General ||
           i || Architecture || architecture_config.md
           ii || Our Approach || our_approach.md
           iii || Our Approach || our_approach.md
           iiii || CI and Rest || ci_and_rest.md
           i || Summary || summary.md
           """
           let fileRepositoryMock = FileIORepositoringMock()
           
           let tableOfContentPrinter = TableOfContentPrinter(rowFactory: TableRowLinkedFactory())
           let documentBodyPrinter = DocumentBodyPrinter()
           let sut = Generator(fileRepository: fileRepositoryMock,
                               tableOfContentPrinter: tableOfContentPrinter,
                               documentBodyPrinter: documentBodyPrinter)
           
           let rootNode = sut.makeNodesLinkedList(from: documentShape)
           let head = Node(intent: "", title: "", content: "")
           head.nextSiblingNode = rootNode

           let tableOfContent = sut.printTitles(from: head, base: "")
           let content = sut.printContent(from: head, base: "")
           let document = Doc(tableOfContent: tableOfContent,
                              content: content)
           
           let expectedDocumentShape = """
           
           ##  1.0 General

           ##  2.0 Architecture

           ###  2.1.0 Our Approach

           ####  2.1.1.0 Our Approach

           ####  2.1.1.1.0 CI and Rest

           ##  3.0 Summary

           """
       
           XCTAssertEqual(expectedDocumentShape, document.content)
       }
}
