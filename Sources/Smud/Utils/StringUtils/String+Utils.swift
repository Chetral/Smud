//
// String+Utils.swift
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

extension String {
    public func forEachLine(handler: (_ line: String, _ stop: inout Bool) throws ->()) rethrows {
        let lines = replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .components(separatedBy: "\n")
        var stop = false
        for line in lines {
            try handler(line, &stop)
            if stop {
                return
            }
        }
    }

    public func forEachLine(handler: (_ index: Int, _ line: String, _ stop: inout Bool) throws ->()) rethrows {
        var index = 0
        try forEachLine { line, stop in
            try handler(index, line, &stop)
            index += 1
        }
    }

    public func hasPrefix(_ prefix: String, caseInsensitive: Bool) -> Bool {
        if caseInsensitive {
            return nil != range(of: prefix,
                                options: [.caseInsensitive, .anchored])
        }
        return hasPrefix(prefix)
    }

    public func hasPrefix(oneOf prefixes: [String], caseInsensitive: Bool) -> Bool {
        for prefix in prefixes {
            if hasPrefix(prefix, caseInsensitive: caseInsensitive) {
                return true
            }
        }
        return false
    }

    public func isPrefix(of string: String, caseInsensitive: Bool = false) -> Bool {
        return string.hasPrefix(self, caseInsensitive: caseInsensitive)
    }
    
    public func isPrefix(ofOneOf strings: [String], caseInsensitive: Bool = false) -> Bool {
        for item in strings {
            if isPrefix(of: item, caseInsensitive: caseInsensitive) {
                return true
            }
        }
        return false
    }
    
    public func isEqual(to string: String, caseInsensitive: Bool = false) -> Bool {
        switch caseInsensitive {
        case false: return self == string
        case true: return caseInsensitiveCompare(string) == .orderedSame
        }
    }
    
    public func isEqual(toOneOf strings: [String], caseInsensitive: Bool = false) -> Bool {
        for item in strings {
            if isEqual(to: item, caseInsensitive: caseInsensitive) {
                return true
            }
        }
        return false
    }

    public func droppingPrefix(count: Int = 1) -> Substring {
        let from = index(startIndex, offsetBy: count)
        return self[from...]
    }
    
    public func droppingSuffix(count: Int = 1) -> Substring {
        let to = index(endIndex, offsetBy: -count)
        return self[..<to]
    }
    
    public func capitalizingFirstLetter() -> String {
        let first = String(prefix(1)).capitalized
        let other = String(dropFirst())
        return first + other
    }
    
    public mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

