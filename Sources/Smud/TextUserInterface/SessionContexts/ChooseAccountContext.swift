//
// CreateAccountContext.swift
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


public final class ChooseAccountContext: SessionContext {
    let smud: Smud
    let socket: Socket

    public init(smud: Smud, socket: Socket) {
        self.smud = smud
        self.socket = socket
    }

    public static var name = "chooseAccount"

    public func greet(session: Session) {
        // print("Socket: \(session.socket.socketfd):\(String(describing:session.socket.signature?.description))")
        // session.sendPrompt("Please enter your email address: ", socket: session.socket)
        session.sendPrompt("Please enter your email address: ", socket: session.socket)
    }

    public func processResponse(args: Scanner, session: Session) throws -> ContextAction {
        guard let email = args.scanWord(),
            Email.isValidEmail(email) else { return .retry(reason: "Invalid email address.") }

        if let account = smud.db.account(email: email) {
            session.account = account
            return .next(context: PlayerNameContext(smud: smud, socket: session.socket))
        }

        let account = Account(smud: smud)
        account.email = email
        account.scheduleForSaving()
        smud.db.addToIndexes(account: account)

        session.account = account

        //session.send("Confirmation email has been sent to your email address.")
        //return .next(context: ConfirmationCodeContext(smud: smud))
        return .next(context: PlayerNameContext(smud: smud, socket: session.socket))
    }
}
