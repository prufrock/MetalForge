//
// Created by David Kanenwisher on 4/1/22.
//

struct GMDoor {
    let position: Float2
    let direction: Float2
    let texture: GMTexture
    let isVertical: Bool

    // Handles opening and closing the door
    var state: GMDoorState = .closed
    var time: Float = 0
    let duration: Float = 0.5
    let closeDelay: Float = 3

    init(position: Float2, isVertical: Bool) {
        self.position = position
        self.isVertical = isVertical

        if isVertical {
            self.direction = Float2(x:0, y: 1)
            self.texture = .door1
        } else {
            self.direction = Float2(x:1, y:0)
            self.texture = .door2
        }
    }
}

enum GMDoorState {
    case closed
    case opening
    case open
    case closing
}

extension GMDoor {
    var rect: GMRect {
        // open the door along the axis by the offset for collision handling
        let position = self.position + direction * (offset - 0.5)
        // make the collision rectangle a little thicker(0.2 units thick)
        let depth = direction.orthogonal * 0.1
        return GMRect(min: position + depth, max: position + direction - depth)
    }

    // The amount the door should be open, also animates opening and closing depending on state
    var offset: Float {
        let t = min(1, time / duration)
        switch state {
        case .closed:
             return 0
        case .opening:
            return GMEasing.easeInEaseOut(t)
        case .open:
            return 1
        case .closing:
            return 1 - GMEasing.easeInEaseOut(t)
        }
    }

    var billboard: GMBillboard {
        GMBillboard(
            // the billboard moves along its axis by the offset to open and close
            start: position + direction * (offset - 0.5),
            direction: direction,
            length: 1,
            position: isVertical ? Float2(position.x, position.y + offset) : Float2(position.x + offset, position.y),
            texture: texture
        )
    }

    /*
     Determines if a ray hit the door. If it does returns the displacement vector.
     */
    func hitTest(_ ray: GMRay) -> Float2? {
        billboard.hitTest(ray)
    }

    mutating func update(in world: inout GMWorld) {
        switch state {
        case .closed:
            // open the door if the player touches it
            // or if a living monster touches it
            if world.player.intersection(with: self) != nil  ||
                   world.monsters.contains(where: { monster in
                       monster.isDead == false &&
                           monster.intersection(with: self) != nil
                   }) {
                print("transition to open")
                state = .opening
                time = 0
            }
        case .opening:
            // when the animation is complete change to open
            if time >= duration {
                state = .open
                time = 0
                world.playSound(.doorSlide, at: position)
            }
        case .open:
            if time >= closeDelay {
                state = .closing
                time = 0
            }
        case .closing:
            // when the animation is complete change to open
            if time >= duration {
                state = .closed
                time = 0
                world.playSound(.doorSlide, at: position)
            }
        }
    }
}
