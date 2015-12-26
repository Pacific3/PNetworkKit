
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
    
    public func p_setPrimaryColor<C: ColorConvertible>(
        primary: C,
        secondaryColor secondary: C,
        terciaryColor terciary: C) {
            p_setPrimaryColor(primary.color(),
                secondaryColor: secondary.color(),
                terciaryColor: terciary.color()
            )
    }
}
