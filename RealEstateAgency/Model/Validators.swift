//
//  Validators.swift
//  Kidcoin
//
//  Created by Mediym on 12/28/18.
//  Copyright © 2018 Mediym. All rights reserved.
//

import Foundation

protocol Validator {
    func validate(value: String?) -> Bool
    var error: String {get}
}

class EmptyStringValidator: Validator {
    
    private(set) var error: String
    
    init(error: String? = nil) {
        if let error = error {
            self.error = error
        } else {
            self.error = "Input string is too short"
        }
    }
    
    func validate(value: String?) -> Bool {
        guard let value = value else {
            return false
        }
        return !value.isEmpty
    }
    
}

class EmailValidator: EmptyStringValidator {
    
    override var error: String {
        get {
            return "Email is incorrect"
        }
    }
    
    override func validate(value: String?) ->Bool {
        guard let value = value else {
            return false
        }
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: value)
    }
}

class NumberValidator: EmptyStringValidator {
    
    override var error: String {
        return "It is not number"
    }
    
    override func validate(value: String?) -> Bool {
        guard let value = value else { return false }
        return Double(value) != nil
    }
}

class PhoneValidator: EmptyStringValidator {
    
    override var error: String {
        get {
            return "Phone has invalid characters"
        }
    }
    
    override func validate(value: String?) ->Bool {
        guard let value = value else {
            return false
        }
        let test = NSPredicate(format:"SELF MATCHES '[\\\\(\\\\)0-9+\\\\- ]+'")
        return test.evaluate(with: value)
    }
}

class AgeValidator: EmptyStringValidator {

    override var error: String {
        get {
            return "Invalid age"
        }
    }

    private let timeInterval: TimeInterval

    init(minimalAge: Double) {
        self.timeInterval = -minimalAge * 365 * 24 * 60 * 60
        super.init()
    }

    override func validate(value: String?) -> Bool {
        guard let value = value, let date = Date.dateUS(from: value) else {
            return false
        }
        return date.timeIntervalSinceNow < timeInterval
    }
}


class NamedStringValidator: Validator {

    private var min: Int
    private var max: Int
    private var minError: String
    private var maxError: String
    internal var name: String
    internal var error: String

    init(name: String, min: Int, max: Int) {
        self.name = name
        self.min = min
        self.max = max
        self.minError = "error.tooShort" + name
        self.maxError = "error.tooLong" + name
        error = ""
    }

    internal func validate(value: String?) -> Bool {
        guard let value = value, !value.isEmpty else {
            error = minError
            return false
        }

        let count = value.utf16.count

        if count < min {
            error = minError
            return false
        } else if count > max {
            error = maxError
            return false
        } else {

            return true
        }
    }
}

class AlphabeticStringValidator: NamedStringValidator {
    private let nonAlphabetic = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ").inverted
    
    override internal func validate(value: String?) -> Bool {
        if super.validate(value: value) {
            if hasNonAlphabetic(string: value!) {
                error = "\(name) contains special characters or space"
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    internal func hasNonAlphabetic(string: String) -> Bool {
        return string.rangeOfCharacter(from: nonAlphabetic) != nil
    }
}

class NOOPValidator: Validator {
    
    internal var error = ""
    
    internal func validate(value: String?) -> Bool {
        return true
    }
}
