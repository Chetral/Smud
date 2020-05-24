//
// Creature+Info.swift
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


extension Creature {
    var textUserInterfaceData: CreatureData { return pluginData() }


    func look(socket: Socket) {
        guard let room = room else {
            send("You aren't standing in any room.", socket: socket)
            return
        }

        let map = room.areaInstance.textUserInterfaceData.renderedAreaMap?.fragment(near: room, playerRoom: room, horizontalRooms: 3, verticalRooms: 3) ?? ""

        send(room.title, "\n", room.description.wrapping(aroundTextColumn: map, totalWidth: 76, rightMargin: 1, bottomMargin: 1), socket: socket)

        for creature in room.creatures {
            if let mobile = creature as? Mobile {
                //print(mobile.shortDescription)
                send(mobile.shortDescription, socket: socket)
            } else {
                //print(creature.name, " is standing here.")
                send(creature.name, "is standind here.", socket: socket)
            }
        }
    }

    func send(items: [Any], separator: String = "", terminator: String = "", isPrompt: Bool = false, socket: Socket) {
        for session in textUserInterfaceData.sessions {
            session.send(items: items, separator: separator, terminator: terminator, socket: session.socket)
        }
    }

    func send(_ items: Any..., separator: String = "", terminator: String = "\n", isPrompt: Bool = false, socket: Socket) {
        send(items: items, separator: separator, terminator: terminator, socket: socket)
    }
}
