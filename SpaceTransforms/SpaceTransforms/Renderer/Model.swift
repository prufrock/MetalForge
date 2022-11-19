//
//  Model.swift
//  SpaceTransforms
//
//  Created by David Kanenwisher on 11/19/22.
//

import Foundation

protocol Model {
    var v: [F3] {get}
    var s: MSpaces {get}
}

struct Dot: Model {
    let v: [F3] = [F3(0.0, 0.0, 0.0)]
    let s: MSpaces = .model
}

enum BasicModels {
    case dot
}
