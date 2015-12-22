
extension Array {
    public mutating func remove<U: Equatable>(item itemToRemove: U) {
        var index: Int?
        for (idx, item) in self.enumerate() {
            if let item = item as? U
                where item == itemToRemove {
                    index = idx
            }
        }
        
        if let index = index {
            self.removeAtIndex(index)
        }
    }
}
