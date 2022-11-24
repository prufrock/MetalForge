//
//  MFloat.swift
//  SpaceTransforms
//
//  Created by David Kanenwisher on 11/15/22.
//

import Foundation

struct MFloat {
    let s: MSpaces
    let v: Float
}

extension Double {
    var f: Float {
        get {
            Float(self)
        }
    }
}

extension Float {
    func toRadians() -> Float {
        self * (.pi / 180)
    }
}
