//
//  MFloat3.swift
//  SpaceTransforms
//
//  Created by David Kanenwisher on 11/16/22.
//

import Foundation

struct MFloat3 {
    let s: MSpaces
    let v: Float3

    static func +(left: MFloat3, right: Float3) -> MFloat3 {
        let v = left.v + right
        return MFloat3(s: left.s, v: v)
    }
}

typealias Float3 = SIMD3<Float>
