//
// PlayerNameContext.swift
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


final class PlayerNameContext: SessionContext {
    static var name = "playerName"
    let smud: Smud
    let socket: Socket

    init(smud: Smud, socket: Socket) {
        self.smud = smud
        self.socket = socket
    }

    func greet(session: Session) {
        defer { session.sendPrompt("Please choose a name for your character: ", socket: session.socket) }

        guard let accountId = session.account?.accountId else { return }
        let players = smud.db.players(accountId: accountId)
        let playerNames = players.map { v in v.name }.sorted()
        guard !playerNames.isEmpty else { return }

        session.send("Your characters:  ", socket: session.socket)
        for (index, name) in playerNames.sorted().enumerated() {
            session.send("  \(index + 1). \(name)", socket: session.socket)
        }
    }

    func processResponse(args: Scanner, session: Session) throws -> ContextAction {
        guard let lowercasedName = args.scanWord()?.lowercased() else {
            return .retry(reason: nil)
        }

        let badCharacters = smud.playerNameAllowedCharacters.inverted
        guard lowercasedName.rangeOfCharacter(from: badCharacters) == nil else {
            return .retry(reason: smud.playerNameInvalidCharactersMessage)
        }

        let name = lowercasedName.capitalized
        let nameLength = name.count
        guard nameLength >= smud.playerNameLength.lowerBound else {
            return .retry(reason: "Character name is too short")
        }
        guard nameLength <= smud.playerNameLength.upperBound else {
            return .retry(reason: "Character name is too long")
        }

        if let player = smud.db.player(name: name) {
            guard player.account == session.account else {
                return .retry(reason: "Character named '\(name)' already exists. Please choose a different name.")
            }
            player.textUserInterfaceData.sessions.append(session)
            session.creature = player
        } else {
            guard let account = session.account else {
                return .next(context: ChooseAccountContext(smud: smud, socket: session.socket))
            }

            let player = Player(name: name, account: account, world: smud.db.world)
            player.scheduleForSaving()
            smud.db.addToIndexes(player: player)
            session.creature = player
            player.textUserInterfaceData.sessions = [session]
        }

        return .next(context: MainMenuContext(smud: smud, socket: session.socket))
    }
}
