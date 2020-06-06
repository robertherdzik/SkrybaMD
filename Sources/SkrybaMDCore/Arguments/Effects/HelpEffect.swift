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
