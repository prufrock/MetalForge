//
//  Actor.swift
//  SpaceTransforms
//
//  Created by David Kanenwisher on 11/19/22.
//

import Foundation

protocol Actor {
    var position: MF2 {get set}

    var model: BasicModels {get}
    var color: Float3 {get set}

    var modelToUpright:Float4x4 {get}
    var uprightToWorld:Float4x4 {get}
}
