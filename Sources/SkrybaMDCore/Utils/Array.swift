extension Array {
    public subscript(safe x: Int) -> Element? {
        if self.count > x {
            return self[x]
        }
        
        return nil
    }
}
