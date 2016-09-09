//
// Room.swift
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

class Room {
    struct Exit {
        var tag: String
        var description: String
    }
    
    var primaryTag = ""
    var extraTags: [String] = []
    
    var name = ""
    
    var description = ""
    var keywordsText: [String: String] = [:]
    
    var exits: [Direction: Exit] = [:]
    
    func get(property: String) -> String? {
        switch property {
        case "primaryTag": return primaryTag
        case "name": return name
        case "description": return description
        default: return nil
        }
    }
    
    func set(_ property: String, _ value: String) throws {
        switch property {
        case "primaryTag": primaryTag = value
        case "name": name = value
        case "description": description = value
        default: throw PropertyError.notFound(property: property)
        }
    }
}