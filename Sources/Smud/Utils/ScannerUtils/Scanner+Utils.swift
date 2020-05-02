//
// Scanner+Utils.swift
//
// This source file is part of the SMUD open source project
//
// Copyright (c) 2016 SMUD project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See LICENSE.txt for license information
// See AUTHORS.txt for the list of SMUD project authors
//

import Foundation

extension Scanner {
    public func skipping(_ characters: CharacterSet?, closure: () throws->()) rethrows {
        let previous = charactersToBeSkipped
        defer { charactersToBeSkipped = previous }
        charactersToBeSkipped = characters
        try closure()
    }
    
    @discardableResult
    public func skipInteger() -> Bool {
        return scanInteger() != nil
    }
    
    @discardableResult
    public func skipInt32() -> Bool {
        #if os(OSX)
            return scanInt32(nil)
        #else
            return scanInt() != nil
        #endif
    }

    @discardableResult
    public func skipInt64() -> Bool {
        return scanInt64() != nil
    }
    
    @discardableResult
    public func skipUInt64() -> Bool {
        return scanUInt64() != nil
    }
    
    @discardableResult
    public func skipFloat() -> Bool {
        return scanFloat() != nil
    }
    
    @discardableResult
    public func skipDouble() -> Bool {
        return scanDouble() != nil
    }
    
    @discardableResult
    public func skipHexUInt32() -> Bool {
        return scanHexUInt32() != nil
    }
    
    @discardableResult
    public func skipHexUInt64() -> Bool {
        return scanHexUInt64() != nil
    }
    
    @discardableResult
    public func skipHexFloat() -> Bool {
        return scanHexFloat() != nil
    }
    
    @discardableResult
    public func skipHexDouble() -> Bool {
        return scanHexDouble() != nil
    }

    @discardableResult
    public func skipString(_ string: String) -> Bool {
        return scanString(string) != nil
    }

    @discardableResult
    public func skipCharacters(from: CharacterSet) -> Bool {
        return scanCharacters(from: from) != nil
    }
    
    @discardableResult
    public func skipUpTo(_ string: String) -> Bool {
        return scanUpTo(string) != nil
    }

    @discardableResult
    public func skipUpToCharacters(from set: CharacterSet) -> Bool {
        return scanUpToCharacters(from: set) != nil
    }

    public func peekUtf16CodeUnit() -> UTF16.CodeUnit? {
        let originalScanLocation = scanLocation
        defer { scanLocation = originalScanLocation }
        
        let originalCharactersToBeSkipped = charactersToBeSkipped
        defer { charactersToBeSkipped = originalCharactersToBeSkipped }
        
        if let characters = charactersToBeSkipped {
            charactersToBeSkipped = nil
            let _ = scanCharacters(from: characters)
        }
        
        guard scanLocation < string.utf16.count else { return nil }
        let index = string.utf16.index(string.utf16.startIndex, offsetBy: scanLocation)
        return string.utf16[index]
    }
    
    public var scanLocationInCharacters: Int {
        let utf16 = string.utf16
        guard let to16 = utf16.index(utf16.startIndex, offsetBy: scanLocation, limitedBy: utf16.endIndex),
            let to = String.Index(to16, within: string) else {
                return 0
        }
        return string.distance(from: string.startIndex, to: to)
    }
    
    private var currentCharacterIndex: String.Index? {
        let utf16 = string.utf16
        guard let to16 = utf16.index(utf16.startIndex, offsetBy: scanLocation, limitedBy: utf16.endIndex),
            let to = String.Index(to16, within: string) else {
                return nil
        }
        // to is a String.CharacterView.Index
        return to
    }
    
    public var parsedText: Substring {
        guard let index = currentCharacterIndex else { return "" }
        return string[..<index]
    }

    public var textToParse: Substring {
        guard let index = currentCharacterIndex else { return "" }
        return string[index...]
    }
    
    public var lineBeingParsed: String {
        let targetLine = self.line()
        var currentLine = 1
        var line = ""
        line.reserveCapacity(256)
        for character in string {
            if currentLine > targetLine {
                break
            }
            
            if character == "\n" || character == "\r\n" {
                currentLine += 1
                continue
            }
            
            if currentLine == targetLine {
                line.append(character)
            }
        }
        return line
    }

    // Very slow, do not in use in loops
    public func line() -> Int {
        var newLinesCount = 0
        parsedText.forEach {
            if $0 == "\n" || $0 == "\r\n" {
                newLinesCount += 1
            }
        }
        return 1 + newLinesCount
    }
    
    // Very slow, do not in use in loops
    public func column() -> Int {
        let text = parsedText
        if let range = text.range(of: "\n", options: .backwards) {
            return text.distance(from: range.upperBound, to: text.endIndex) + 1
        }
        return parsedText.count + 1
    }
}

