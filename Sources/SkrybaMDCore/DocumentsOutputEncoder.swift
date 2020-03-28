
public struct MDSign {
    
    public struct Header {
        public static let big = "## "
        public static let small = "### "
    }
    
    public struct List {
        public static let sign = "#### "
    }
}

public struct DocumentsOutputEncoder {
    
    public static func encode(doc: Doc, printerOutput: (String) -> Void) {
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
