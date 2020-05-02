//
// RenderedAreaMap.swift
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


class RenderedAreaMap {
    typealias MapsByPlane = [/* Plane */ Int: /* Plane map */ [[Character]]]

    let areaMap: AreaMap
    var mapsByPlane = MapsByPlane()
    var renderedRoomCentersByRoom = [Room: AreaMapPosition]() // AreaMapPosition is used here only for convenience, its x and y specify room center offset in characters relative to top-left corner of the rendered map
    
    var version: Int?

    let roomWidth = 3
    let roomHeight = 1
    let roomSpacingWidth = 1
    let roomSpacingHeight = 1
    let fillCharacter: Character = "."

    init(areaMap: AreaMap) {
        self.areaMap = areaMap
    }

    public func fragment(near room: Room, playerRoom: Room? = nil, horizontalRooms: Int, verticalRooms: Int) -> String {
        let width = roomWidth * horizontalRooms + roomSpacingWidth * (horizontalRooms + 1)
        let height = roomHeight * verticalRooms + roomSpacingHeight * (verticalRooms + 1)

        return fragment(near: room, playerRoom: playerRoom, width: width, height: height)
    }

    public func fragment(near room: Room, playerRoom: Room? = nil, width: Int, height: Int, pad: Bool = true) -> String {
        if version == nil || version != areaMap.version {
            render()
        }

        guard let roomCenter = renderedRoomCentersByRoom[room] else { return "" }
        guard let map = mapsByPlane[roomCenter.plane] else { return "" }
        guard map.count > 0 && map[0].count > 0 else { return "" }

        let plane = roomCenter.plane
        let mapRange = AreaMapRange(from: AreaMapPosition(0, 0, plane), to: AreaMapPosition(map[0].count, map.count, plane))

        let topLeftHalf = AreaMapPosition(width / 2, height / 2, 0)
        let bottomRightHalf = AreaMapPosition(width, height, 0) - topLeftHalf

        let from = pad
            ? roomCenter - topLeftHalf
            : upperBound(roomCenter - topLeftHalf, mapRange.from)
        let to = pad
            ? roomCenter + bottomRightHalf
            : lowerBound(roomCenter + bottomRightHalf, mapRange.to)

        let topLeftPadding = upperBound(mapRange.from - from, AreaMapPosition(0, 0, 0))
        let bottomRightPadding = upperBound(to - mapRange.to, AreaMapPosition(0, 0, 0))

        var fragmentLines = [String]()

        let playerRoomCenter = playerRoom != nil
            ? renderedRoomCentersByRoom[playerRoom!]
            : nil
        for y in from.y..<to.y {
            guard y - from.y >= topLeftPadding.y && to.y - y - 1 >= bottomRightPadding.y else {
                fragmentLines.append(String(repeating: String(fillCharacter), count: to.x - from.x))
                continue
            }

            var line = ""
            line.reserveCapacity(to.x - from.x)

            line += String(repeating: String(fillCharacter), count: topLeftPadding.x)
            line += String(map[y][from.x + topLeftPadding.x..<to.x - bottomRightPadding.x])
            line += String(repeating: String(fillCharacter), count: bottomRightPadding.x)

            if let playerRoomCenter = playerRoomCenter, playerRoomCenter.y == y {
                let leftBracketPosition = playerRoomCenter.x - roomWidth / 2
                let rightBracketPosition = playerRoomCenter.x + roomWidth / 2
                if leftBracketPosition >= from.x && rightBracketPosition < to.x {
                    let index = line.index(line.startIndex, offsetBy: leftBracketPosition - from.x)
                    line.replaceSubrange(index...index, with: "[")
                }
                if rightBracketPosition >= from.x && rightBracketPosition < to.x {
                    let index = line.index(line.startIndex, offsetBy: rightBracketPosition - from.x)
                    line.replaceSubrange(index...index, with: "]")
                }
            }

            fragmentLines.append(line)
        }
        
        return fragmentLines.joined(separator: "\n")
    }

    func render() {
        version = areaMap.version
        
        mapsByPlane.removeAll()
        
        let verticalPassage = "\(fillCharacter)|\(fillCharacter)"
        let horizontalPadding = 1
        let verticalPadding = 1

        for (plane, range) in areaMap.rangesByPlane {
            let logicalWidth = range.size(axis: .x)
            let logicalHeight = range.size(axis: .y)
            let width = roomWidth * logicalWidth + roomSpacingWidth * (logicalWidth - 1)
            let height = roomHeight * logicalHeight + roomSpacingHeight * (logicalHeight - 1)
            let renderedEmptyRow = [Character](repeating: fillCharacter, count: width + 2 * horizontalPadding)
            mapsByPlane[plane] = [[Character]](repeating: renderedEmptyRow, count: height + 2 * verticalPadding)
        }
        
        for (position, element) in areaMap.mapElementsByPosition {
            let plane = position.plane
            guard mapsByPlane[plane] != nil else { continue }
            guard let range = areaMap.rangesByPlane[plane] else { continue }
            
            let x = horizontalPadding + (roomWidth + roomSpacingWidth) * (position.x - range.from.x)
            let y = verticalPadding + (roomHeight + roomSpacingHeight) * (position.y - range.from.y)
            
            switch element {
            case .room(let room):
                renderedRoomCentersByRoom[room] = AreaMapPosition(x + roomWidth / 2, y, plane)
                mapsByPlane[plane]![y].replaceSubrange(x..<(x + roomWidth), with: "( )")
                if room.exits[.east] != nil {
                    mapsByPlane[plane]![y][x + roomWidth] = "-"
                }
                if room.exits[.south] != nil {
                    mapsByPlane[plane]![y + roomHeight].replaceSubrange(x..<(x + roomWidth), with: verticalPassage)
                }
                if room.exits[.up] != nil && room.exits[.down] != nil {
                    mapsByPlane[plane]![y][x + roomWidth / 2] = "%"
                } else if room.exits[.up] != nil {
                    mapsByPlane[plane]![y][x + roomWidth / 2] = "^"
                } else if room.exits[.down] != nil {
                    mapsByPlane[plane]![y][x + roomWidth / 2] = "v"
                }
            case .passage(let axis):
                switch axis {
                case .x:
                    mapsByPlane[plane]![y].replaceSubrange(x..<(x + roomWidth), with: "---")
                    mapsByPlane[plane]![y][x + roomWidth] = "-"
                case .y:
                    mapsByPlane[plane]![y].replaceSubrange(x..<(x + roomWidth), with: verticalPassage)
                    mapsByPlane[plane]![y + roomHeight].replaceSubrange(x..<(x + roomWidth), with: verticalPassage)
                case .plane:
                    mapsByPlane[plane]![y].replaceSubrange(x..<(x + roomWidth), with: " * ")
                }
            }
        }
    }
}
