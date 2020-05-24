//
// Session.swift
//
// This source file is part of the SMUD open source project
//
// Copyright (c) 2016 SMUD project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SMUD project authors
//
import Socket

public protocol Session: class {
    var textUserInterface: TextUserInterface { get }
    var context: SessionContext? { get set }
    var socket : Socket { get }

    var account: Account? { get set }
    var creature: Creature? { get set }

    func send(items: [Any], separator: String, terminator: String, isPrompt: Bool, socket: Socket)
}

public extension Session {
    func send(items: [Any], separator: String = "", terminator: String = "\n", socket: Socket) {
        send(items: items, separator: separator, terminator: terminator, isPrompt: false, socket: socket)
    }

    func send(_ items: Any..., separator: String = "", terminator: String = "\n", socket: Socket) {
        send(items: items, separator: separator, terminator: terminator, socket: socket)
    }

    func sendPrompt(items: [Any], separator: String = "", terminator: String = "\n", socket: Socket) {
        var items = items
        items.insert("\n", at: 0)
        send(items: items, separator: separator, terminator: "", isPrompt: true, socket: socket)
    }

    func sendPrompt(_ items: Any..., separator: String = "", terminator: String = "\n", socket: Socket) {
        sendPrompt(items: items, separator: separator, terminator: "", socket: socket)
    }
}
