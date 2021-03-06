//
// World.swift
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

public class World {
    public let smud: Smud
    public var areasById = [String: Area]()
    // TODO: consider using hash or linked list, otherwise addition/deletion is too costly
    public var creatures = [Creature]()
    
    public init(smud: Smud) {
        self.smud = smud
    }

    // FIXME: should work when areaId is specified, but instance is not specified
    public func resolveRoom(link: Link, defaultInstance: AreaInstance? = nil) -> Room? {
        let roomId = link.entityId

        if link.areaId == nil && link.instanceIndex == nil {
            guard let defaultInstance = defaultInstance else { return nil }
            guard let room = defaultInstance.roomsById[roomId] else { return nil }
            return room
        }

        guard let areaId = link.areaId, let instanceIndex = link.instanceIndex else { return nil }
        guard let area = areasById[areaId] else { return nil }
        guard let areaInstance = area.instancesByIndex[instanceIndex] else { return nil }
        guard let room = areaInstance.roomsById[roomId] else { return nil }

        return room
    }
}
