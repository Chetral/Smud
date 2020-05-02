//
// ConsoleSession.swift
//
// This source file is part of the SMUD open source project
//
// Copyright (c) 2016 SMUD project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SMUD project authors
//

import Foundation


class ConsoleSession: Session {
    public var textUserInterface: TextUserInterface
    
    public var context: SessionContext? {
        didSet {
            context?.greet(session: self)
        }
    }
    
    public var account: Account?
    public var creature: Creature?

    public init(textUserInterface: TextUserInterface) {
        self.textUserInterface = textUserInterface
    }
    
    public func send(items: [Any], separator: String, terminator: String, isPrompt: Bool) {
        var first = true
        for item in items {
            if first {
                first = false
            } else {
                print(separator, terminator: "")
            }
            print(item, terminator: "")
        }
        print(terminator: terminator)
        //if isPrompt {
        //    print("[IAC GA]", terminator: "")
        //}
    }
}
