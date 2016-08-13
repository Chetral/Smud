//
// MigrationController.swift
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

class MigrationController {
    static var migrator = DatabaseMigrator()

    static func migrate() throws {
        // Migrations run in order, once and only once. When a user upgrades the application, only non-applied migrations are run.

        // v1.0 database
        migrator.registerMigration("createTables") { db in
            try db.execute(
                "CREATE TABLE accounts (" +
                    "account_id INTEGER PRIMARY KEY, " +
                    "email TEXT NOT NULL COLLATE NOCASE" +
                ");" +
                "CREATE INDEX accounts_email ON accounts(email); "
            )
        }

        // Migrations for future versions will be inserted here:
        //
        // // v2.0 database

        try migrator.migrate(DB.queue)
    }
}
