//
// Created by David Kanenwisher on 2/19/22.
//

public struct Monster {
    var position: Float2
    let radius: Float = 0.25

    public init(position: Float2) {
        self.position = position
    }
}

extension Monster {
    var rect: Rect {
        let halfSize = Float2(x: radius, y: radius)
        return Rect(min: position - halfSize, max: position + halfSize)
    }
}