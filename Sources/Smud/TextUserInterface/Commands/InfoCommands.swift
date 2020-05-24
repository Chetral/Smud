//
// InfoCommands.swift
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


class InfoCommands {
    func register(with router: CommandRouter) {
        router[""] = refreshPrompt
        router["look"] = look
        router["map"] = map
        router["exits"] = exits
    }

    func refreshPrompt(context: CommandContext) -> CommandAction {
        return .accept
    }

    func look(context: CommandContext) -> CommandAction {
        context.creature.look(socket: context.socket)

        return .accept
    }

    func map(context: CommandContext) -> CommandAction {
        guard let room = context.room else {
            context.send("You aren't standing in any room.", socket: context.socket)
            return .accept
        }

        guard let map = context.areaInstance?.textUserInterfaceData.renderedAreaMap else {
            context.send("This area has no map.", socket: context.socket)
            return .accept
        }

        context.send(map.fragment(near: room, width: 100, height: 100, pad: false), socket: context.socket)

        return .accept
    }

    func exits(context: CommandContext) -> CommandAction {
        guard let room = context.room else {
            context.send("You aren't standing in any room.", socket: context.socket)
            return .accept
        }

        for (direction, link) in room.orderedExits {
            guard let neighborRoom = room.resolveLink(link: link) else { continue }
            let directionName = direction.rawValue.capitalizingFirstLetter()
            context.send("\(directionName): \(neighborRoom.title)", socket: context.socket)
        }

        return .accept
    }
}
