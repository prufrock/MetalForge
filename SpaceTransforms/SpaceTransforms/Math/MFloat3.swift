//
//  MFloat3.swift
//  SpaceTransforms
//
//  Created by David Kanenwisher on 11/16/22.
//

import Foundation

struct MFloat3 {
    let space: MSpaces
    let value: Float3

    static func +(left: MFloat3, right: Float3) -> MFloat3 {
        let v = left.value + right
        return MFloat3(space: left.space, value: v)
    }
}

typealias MF3 = MFloat3

typealias Float3 = SIMD3<Float>
typealias F3 = Float3
