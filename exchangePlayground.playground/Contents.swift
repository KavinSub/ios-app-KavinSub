//: Playground - noun: a place where people can play

import UIKit

let string = "32qsdasdfj2"

let numberSet: Set<Character> = Set("0123456789".characters)
let characters = Array(string.characters)

var returnable = ""

for character in characters{
    if numberSet.contains(character){
        returnable += String(character)
    }
}

returnable