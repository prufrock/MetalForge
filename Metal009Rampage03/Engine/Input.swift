//
// Created by David Kanenwisher on 12/26/21.
//

import Foundation

public struct Input {
    public var speed: Float
    public var rotation: Float2x2
    public var rotation3d: Float4x4
    public var showMap: Bool
    public var drawWorld: Bool

    public init(
        speed: Float,
        rotation: Float2x2,
        rotation3d: Float4x4,
        showMap: Bool,
        drawWorld: Bool
    ) {
        self.speed = speed
        self.rotation = rotation
        self.rotation3d = rotation3d
        self.showMap = showMap
        self.drawWorld = drawWorld
    }
}
