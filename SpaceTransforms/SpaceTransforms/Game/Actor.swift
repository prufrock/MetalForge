//
//  Actor.swift
//  SpaceTransforms
//
//  Created by David Kanenwisher on 11/19/22.
//

import Foundation

struct Actor {
    var position: MF2 = MF2(space: .world, value: F2(0.0, 0.0))
    var model: BasicModels
}
