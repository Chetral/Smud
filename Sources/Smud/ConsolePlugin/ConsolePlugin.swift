//
// ConsolePlugin.swift
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
import Dispatch
import Socket

public class ConsolePlugin: SmudPlugin {
    typealias T = ConsolePlugin

    let smud: Smud
    let textUserInterface = TextUserInterface()
    let session: ConsoleSession
    var inputMaximumLineLength = 512
    public var socket: Socket

    public init(smud: Smud, socket: Socket) {
        self.smud = smud
        self.socket = socket
        session = ConsoleSession(textUserInterface: textUserInterface, socket: socket)
    }

    public func willEnterGameLoop() {
        var readData=Data(capacity:EchoServer.bufferSize)
        //print("TextUserInterfacePlugin: willEnterGameLoop()")
        print("Registering text user interface commands")
        textUserInterface.registerCommands()

        print("Activating console session")
        session.context = ChooseAccountContext(smud: smud, socket: self.socket)

        DispatchQueue.global(qos: .background).async {
            var eof = false
            var bytesRead: Int = 0
            repeat {
            //    autoreleasepool {
            do {
              bytesRead = try self.socket.read(into:&readData)
            } catch {
              print("errore nel read del socket \(self.socket.socketfd)")
            }
              if bytesRead > 0 {
                guard let response=String(data:readData,encoding:.utf8) else {
                  print(" Error decoding response...")
                  readData.count = 0
                  break
                }

                  let line = response.trimmingCharacters(in : .whitespacesAndNewlines)

                //if response == readLine(strippingNewline: true) {
                    DispatchQueue.main.async {
                          self.process(line: line, socket: self.socket)
                      }
              //  } else {
              //        eof = true
                      //print("")
                //  }
                }
              } while !eof
                DispatchQueue.main.async {
                  self.smud.isTerminated = true
              }
        }
    }

    private func process(line: String, socket: Socket) {
        var line = line
        if line.count > inputMaximumLineLength {
            session.send("WARNING: Your input was truncated.", socket: session.socket)
            line = String(line.prefix(upTo: line.index(
                line.startIndex, offsetBy: inputMaximumLineLength)))
        }

        guard let context = session.context else { return }
        let args = Scanner(string: line)

        let action: ContextAction
        do {
            action = try context.processResponse(args: args, session: session)
        } catch {
            session.send(smud.internalErrorMessage, socket: session.socket)
            print("Error in context \(context): \(error)")
            context.greet(session: session)
            return
        }

        switch action {
        case .retry(let reason):
            if let reason = reason {
                session.send(reason, socket: session.socket)
            }
            context.greet(session: session)
        case .next(let context):
            session.context = context
        case .closeSession:
            // Return to registration instead?
            //smud.isTerminated = true
            let socketclose = session.socket
            socketclose.close()

        }
    }
}
