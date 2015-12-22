extension UIUserNotificationSettings {
    public func contains(settings: UIUserNotificationSettings) -> Bool {
        if !types.contains(settings.types) {
            return false
        }
        
        let otherCategories = settings.categories ?? []
        let myCategories = categories ?? []
        
        return myCategories.isSupersetOf(otherCategories)
    }
    
    
    public func settingsByMerging(settings: UIUserNotificationSettings) -> UIUserNotificationSettings {
        let mergedTypes = types.union(settings.types)
        
        let myCategories = categories ?? []
        var existingCategoriesByIdentifiers = Dictionary(sequence: myCategories) { $0.identifier }
        
        let newCategories = settings.categories ?? []
        let newCategoriesByIdentifiers = Dictionary(sequence: newCategories) { $0.identifier }
        
        for (newIdentifier, newCategory) in newCategoriesByIdentifiers {
            existingCategoriesByIdentifiers[newIdentifier] = newCategory
        }
        
        let mergedCategories = Set(existingCategoriesByIdentifiers.values)
        return UIUserNotificationSettings(forTypes: mergedTypes, categories: mergedCategories)
    }
}