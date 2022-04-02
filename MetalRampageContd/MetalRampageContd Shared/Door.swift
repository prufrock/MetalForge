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
            self.texture = .door1
        } else {
            self.direction = Float2(x:1, y:0)
            self.texture = .door2
        }
    }
}

extension Door {
    var rect: Rect {
        let position = self.position - direction * 0.5
        return Rect(min: position, max: position + direction)
    }

    var billboard: Billboard {
        Billboard(
            start: position - direction * 0.5,
            direction: direction,
            length: 1,
            position: position,
            texture: texture
        )
    }

    /*
     Determines if a ray hit the door. If it does returns the displacement vector.
     */
    func hitTest(_ ray: Ray) -> Float2? {
        billboard.hitTest(ray)
    }
}
