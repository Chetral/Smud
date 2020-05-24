//
//  main.swift
//
//
//  Created by Marco Pirola on 03/05/2020.
//

import Foundation

let smud = Smud()

do {
    try smud.run()
} catch {
    print("\(error)".capitalizingFirstLetter())
}
