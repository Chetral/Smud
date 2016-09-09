//
// DB.swift
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
import GRDB

class DB {
    static let serialSaveQueue = DispatchQueue(label: "Smud.SerialSaveQueue")
    
    static let queue: DatabaseQueue = {
        var config = Configuration()
        config.busyMode = .timeout(10) // Wait 10 seconds before throwing SQLITE_BUSY error
        config.defaultTransactionKind = .deferred
        config.trace = { print("  \($0)") }     // Prints all SQL statements
        
        let dbFilename = "Game/db.sqlite"
        do {
            return try DatabaseQueue(path: dbFilename, configuration: config)
        } catch {
            fatalError("Unable to open database '\(dbFilename)': \(error)")
        }
    }()
    
    static func loadWorldSync() {
        let accountCount = AccountRecord.loadAllEntitiesSync().count
        print("  Loaded \(accountCount) account(s)")
        
        let playerCount = PlayerRecord.loadAllEntitiesSync().count
        print("  Loaded \(playerCount) player(s)")
    }
    
    static func startUpdating() {
        DispatchQueue.main.asyncAfter(deadline: .now() + databaseUpdateInterval) {
            defer { startUpdating() }
            
            //print("Saving")
            savePendingEntities()
        }
//        if #available(OSX 10.12, *) {
//            Timer.scheduledTimer(withTimeInterval: databaseUpdateInterval, repeats: true) { timer in
//                print("Saving")
//            }
//        } else {
//            // Fallback on earlier versions
//        }
        
//        
//        let queue = DispatchQueue.main
//        let timer = DispatchSource.makeTimerSource(flags: [], queue: queue)
//        let interval = databaseSaveInterval
//        let block: () -> () = {
//            print("Saving")
//        }
//        let fireTime = DispatchTime.now() + interval
//        if let leeway = databaseSaveLeeway {
//            timer.scheduleRepeating(deadline: fireTime, interval: interval, leeway: leeway)
//        } else {
//            timer.scheduleRepeating(deadline: fireTime, interval: interval)
//        }
//        timer.setEventHandler(handler: block)
//        timer.resume()
    }
    
    static func savePendingEntities() {
        AccountRecord.saveModifiedEntitiesAsync() { count in
            if count > 0 { print("\(count) account(s) saved") }

            // Accounts need to be saved before players are saved.
            // Players depend on accountIds being assigned.
            PlayerRecord.saveModifiedEntitiesAsync() { count in
                if count > 0 { print("\(count) player(s) saved") }
            }
        }
    }
}



