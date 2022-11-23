//
//  MFloat2.swift
//  SpaceTransforms
//
//  Created by David Kanenwisher on 11/15/22.
//

import Foundation
import simd

struct MFloat2 {
    let space: MSpaces
    var value: Float2

    static func +(left: MFloat2, right: Float2) -> MFloat2 {
        let v = left.value + right
        return MFloat2(space: left.space, value: v)
    }
}

typealias MF2 = MFloat2

typealias Float2 = SIMD2<Float>
typealias F2 = Float2

extension Float2 {
    var length : Float {
        (x * x + y * y).squareRoot()
    }
}
