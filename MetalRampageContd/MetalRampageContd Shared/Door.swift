//
// Created by David Kanenwisher on 4/1/22.
//

struct Door {
    let position: Float2
    let direction: Float2
    let texture: Texture

    init(position: Float2, isVertical: Bool) {
        self.position = position

        if isVertical {
            self.direction = Float2(x:0, y: 1)
            self.texture = .door
        } else {
            self.direction = Float2(x:1, y:0)
            self.texture = .door2
        }
    }
}

extension Door {
    var billboard: Billboard {
        Billboard(
            start: position - direction * 0.5,
            direction: direction,
            length: 1,
            position: position,
            texture: texture
        )
    }
}
