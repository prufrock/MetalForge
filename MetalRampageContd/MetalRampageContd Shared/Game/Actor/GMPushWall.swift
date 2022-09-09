//
// Created by David Kanenwisher on 4/6/22.
//

struct GMPushWall: GMActor {
    // don't store an unneeded property
    var isDead: Bool { false }
    let radius: Float = 0.5
    var position: Float2
    let tile: GMTile

    // make it movable
    let speed: Float = 0.25
    var velocity: Float2

    // allow it to loop it's sound
    let soundChannel: Int

    init(position: Float2, tile: GMTile, soundChannel: Int) {
        self.position = position
        self.tile = tile
        self.velocity = Float2(x: 0, y: 0)
        self.soundChannel = soundChannel
    }
}

extension GMPushWall {
    // The collision rectangle
    var rect: GMRect {
        GMRect(
            min: position - Float2(x: 0.5, y: 0.5),
            max: position + Float2(x: 0.5, y: 0.5)
        )
    }

    var isMoving: Bool {
        velocity.x != 0 || velocity.y != 0
    }

    mutating func update(in world: inout GMWorld) {
        // allows `update` to know the exact moment the wall starts moving or comes to a rest
        // if it started moving `wasMoving` is false and if it stopped moving `wasMoving` is true.
        let wasMoving = isMoving
        // if wall is moving don't change anything
        // otherwise move it in the direction it was pushed but only along the axis is was pushed the most from since it
        // can't be allowed to go sideways.
        if isMoving == false, let intersection = world.player.intersection(with: self) {
            let direction: Float2
            if abs(intersection.x) > abs(intersection.y) {
                direction = Float2(x: intersection.x > 0 ? 1 : -1, y: 0)
            } else {
                direction = Float2(x: 0, y: intersection.y > 0 ? 1 : -1)
            }
            if !world.map.tile(at: position + direction, from: position).isWall {
                print("pushed the wall")
                velocity = direction * speed
            }
        }

        // is that another wall? stop moving and give it a tiny bit of rounding error to keep it from getting hung up.
        if let intersection = self.intersection(with: world), abs(intersection.x) > 0.001 || abs(intersection.y) > 0.001 {
            // let it rest
            velocity = Float2(x: 0, y: 0)
            // center it in the tile just in case
            position.x = position.x.rounded(.down) + 0.5
            position.y = position.y.rounded(.down) + 0.5
        }


        if isMoving {
            world.playSound(.wallSlide, at: position, in: soundChannel)
        } else if !isMoving {
            world.playSound(nil, at: position, in: soundChannel)
            if wasMoving {
                world.playSound(.wallThud, at: position)
            }
        }
    }

    // The billboards are used for hitTest what things can see and for rendering
    var billboards: [GMBillboard] {
        let topLeft = rect.min, bottomRight = rect.max
        let topRight = Float2(x: bottomRight.x, y: topLeft.y)
        let bottomLeft = Float2(x: topLeft.x, y: bottomRight.y)
        let textures = tile.textures
        // The push wall has 4 walls so it had 4 billboards placed into position
        return [
            GMBillboard(start: topLeft, direction: Float2(x: 0, y: 1), length: 1, position: Float2(position.x + 0.5, position.y), textureType: .wall, textureId: textureId(for: textures[0]), textureVariant: .none),
            GMBillboard(start: topRight, direction: Float2(x: -1, y: 0), length: 1, position: Float2(position.x, position.y - 0.5), textureType: .wall, textureId: textureId(for: textures[1]), textureVariant: .none),
            GMBillboard(start: bottomRight, direction: Float2(x: 0, y: -1), length: 1, position: Float2(position.x - 0.5, position.y), textureType: .wall, textureId: textureId(for: textures[0]), textureVariant: .none),
            GMBillboard(start: bottomLeft, direction: Float2(x: 1, y: 0), length: 1, position: Float2(position.x, position.y + 0.5), textureType: .wall, textureId: textureId(for: textures[1]), textureVariant: .none),
        ]
    }

    private func textureId(for texture: GMTexture) -> UInt32 {
        switch texture {
        case .wall:
            return 0
        case .crackWall, .crackWall2:
            return 1
        case .slimeWall, .slimeWall2:
            return 2
        default:
            return 0
        }
    }
}