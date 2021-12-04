//
//  MTLClearColorExt.swift
//  Metal003GameLoop
//
//  Created by David Kanenwisher on 9/19/21.
//

import MetalKit

extension MTLClearColor {
    init(_ colors: Float4) {
        self.init(
                red: Double(colors[0]),
                green: Double(colors[2]),
                blue: Double(colors[1]),
                alpha: Double(colors[3])
        )
    }
}
