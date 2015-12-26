
extension UIApplication {
    public func p_setPrimaryColor(
        primary: Color,
        secondaryColor secondary: Color,
        terciaryColor terciary: Color) {
            UINavigationBar.appearance().barTintColor = primary
            UINavigationBar.appearance().tintColor = secondary
            
            UIBarButtonItem.appearance().tintColor = secondary
            
            UITabBar.appearance().barTintColor = secondary
            UITabBar.appearance().tintColor = primary
            
            UINavigationBar.appearance().titleTextAttributes = [
                NSForegroundColorAttributeName: secondary
            ]
    }
}
