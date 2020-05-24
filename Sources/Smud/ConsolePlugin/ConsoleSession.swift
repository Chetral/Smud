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
import Socket


class ConsoleSession: Session {


    public var textUserInterface: TextUserInterface
    public var socket : Socket

    public var context: SessionContext? {
        didSet {
            context?.greet(session: self)
        }
    }


    public var account: Account?
    public var creature: Creature?

    public init(textUserInterface: TextUserInterface, socket: Socket) {
        self.textUserInterface = textUserInterface
        self.socket = socket
    }

    public func send(items: [Any], separator: String, terminator: String, isPrompt: Bool, socket: Socket) {
//        var first = true

        for item in items {
              do {
              //  print("Socket: \(socket.socketfd):\(String(describing:socket.signature?.description))")
                try socket.write(from: item as! String) }
                catch {
                  guard let socketError = error as? Socket.Error else {
                    print("\(socket.remoteHostname):\(socket.remotePort)")
                    return
                  }
              }

        } // end for
    }


}
