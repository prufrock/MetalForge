//
// Created by David Kanenwisher on 12/26/21.
//

import Foundation

struct GMInput {
    var speed: Float
    var rotation: Float2x2
    var rotation3d: Float4x4
    var showMap: Bool
    var drawWorld: Bool
    var isFiring: Bool
    var isTouching: Bool
    var touchCoords: Float2?

    init(
        speed: Float,
        rotation: Float2x2,
        rotation3d: Float4x4,
        isFiring: Bool,
        showMap: Bool,
        drawWorld: Bool,
        isTouching: Bool,
        touchCoords: Float2? = nil
    ) {
        self.speed = speed
        self.rotation = rotation
        self.rotation3d = rotation3d
        self.isFiring = isFiring
        self.showMap = showMap
        self.drawWorld = drawWorld
        self.isTouching = isTouching
        self.touchCoords = touchCoords
    }
}
