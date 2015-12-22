//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


// Returns true if a string's characters are alphanumeric
func isAlphanumeric(string: String) -> Bool{
    let letters = NSCharacterSet.letterCharacterSet()
    let digits = NSCharacterSet.decimalDigitCharacterSet()
    
    for char in string.unicodeScalars{
        if !(letters.longCharacterIsMember(char.value) || digits.longCharacterIsMember(char.value)){
            return false
        }
    }
    return true
}

let b = isAlphanumeric("ThisShouldReturnTrue")
let c = isAlphanumeric("So123Should12this")
let d = isAlphanumeric("But not this one")
