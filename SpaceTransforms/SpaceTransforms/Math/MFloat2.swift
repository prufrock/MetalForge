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
    let value: Float2
}

typealias MF2 = MFloat2

typealias Float2 = SIMD2<Float>
typealias F2 = Float2
