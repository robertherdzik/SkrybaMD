
public struct IntentFactory {
    
    public init() { }
    
    public func make(baseOn index: Int) -> String {
        String(repeating: Constant.tab, count: index - 1)
    }
}
