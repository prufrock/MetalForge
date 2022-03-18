//
// Created by David Kanenwisher on 2/19/22.
//

public struct Monster: Actor {
    var position: Float2
    let radius: Float = 0.25

    public init(position: Float2) {
        self.position = position
    }
}