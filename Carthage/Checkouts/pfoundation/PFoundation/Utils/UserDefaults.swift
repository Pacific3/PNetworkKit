
private let userDefaults = NSUserDefaults.standardUserDefaults()

// MARK: - User Defaults Get

public func user_defaults_get_string(key: String) -> String {
    let s = userDefaults.objectForKey(key) as? String
    if let s = s {
        return s
    }
    
    return ""
}

public func user_defaults_get_bool(key: String) -> Bool {
    return userDefaults.boolForKey(key)
}

public func user_defaults_get_integer(key: String) -> Int {
    return userDefaults.integerForKey(key)
}


// MARK: - User Defaults Set

public func user_defaults_set_string(key: String, val: String?) -> Bool {
    userDefaults.setObject(val, forKey: key)
    return userDefaults.synchronize()
}

public func user_defaults_set_bool(key: String, val: Bool) -> Bool {
    userDefaults.setBool(val, forKey: key)
    return userDefaults.synchronize()
}

public func user_defaults_set_integer(key: String, val: Int) -> Bool {
    userDefaults.setInteger(val, forKey: key)
    return userDefaults.synchronize()
}
