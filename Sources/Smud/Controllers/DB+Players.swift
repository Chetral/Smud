//
// DB+Players.swift
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


public extension DB {
    func loadPlayers() throws {
        var playerCount = 0
        try enumerateFiles(atPath: smud.playersDirectory) { filename, stop in

            print("  \(filename)")
         
            let directory = URL(fileURLWithPath: smud.playersDirectory, isDirectory: true)
            let fullName = directory.appendingPathComponent(filename, isDirectory: false).relativePath
            let configFile = try ConfigFile(fromFile: fullName)
            let player = try Player(from: configFile, world: smud.db.world)
            
            guard player.filename == filename else {
                throw DBError(kind: .inconsistentPlayerFilename(actual: filename, generated: player.filename))
            }
            
            addToIndexes(player: player)
            
            nextPlayerId = max(player.playerId + 1, nextPlayerId)

            playerCount += 1
        }
        
        print("  \(playerCount) player(s), next id: \(nextPlayerId)")
    }
    
    func savePlayers(completion: (_ count: Int) throws->()) throws {
        var count = 0
        if !modifiedPlayers.isEmpty {
            let directory = URL(fileURLWithPath: smud.playersDirectory, isDirectory: true)
            try FileManager.default.createDirectory(atPath: directory.relativePath, withIntermediateDirectories: true, attributes: nil)
            
            for player in modifiedPlayers {
                let configFile = ConfigFile()
                player.save(to: configFile)
                let fullName = directory.appendingPathComponent(player.filename, isDirectory: false).relativePath
                
                try configFile.save(toFile: fullName, atomically: true)
                
                count += 1
            }
            modifiedPlayers.removeAll(keepingCapacity: true)
        }
        try completion(count)
    }
    
    func createPlayerId() -> Int64 {
        defer { nextPlayerId += 1 }
        return nextPlayerId
    }
    
    func addToIndexes(player: Player) {
        let accountId = player.account.accountId
        
        var v = playersByAccountId[accountId] ?? []
        v.insert(player)
        playersByAccountId[accountId] = v
        
        playersByLowercasedName[player.name.lowercased()] = player
    }
    
    func removeFromIndexes(player: Player) {
        let accountId = player.account.accountId
        if var v = playersByAccountId[accountId] {
            v.remove(player)
            if v.isEmpty {
                playersByAccountId.removeValue(forKey: accountId)
            } else {
                playersByAccountId[accountId] = v
            }
        }

        playersByLowercasedName.removeValue(forKey: player.name.lowercased())
    }
    
    func player(name: String) -> Player? {
        return playersByLowercasedName[name.lowercased()]
    }
    
    func players(accountId: Int64) -> Set<Player> {
        return playersByAccountId[accountId] ?? []
    }
}
