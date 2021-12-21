//
// Created by David Kanenwisher on 12/20/21.
//

import Foundation

public struct Rect {
    var min, max: Float2

    public init(min: Float2, max: Float2) {
        self.min = min
        self.max = max
    }
}
