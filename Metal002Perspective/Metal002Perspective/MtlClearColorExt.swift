//
// Created by David Kanenwisher on 7/15/21.
//

import MetalKit

extension MTLClearColor {
    init(_ colors: float4) {
        self.init(
                red: Double(colors[0]),
                green: Double(colors[2]),
                blue: Double(colors[1]),
                alpha: Double(colors[3])
        )
    }
}
