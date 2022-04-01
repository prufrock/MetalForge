//
// Created by David Kanenwisher on 12/16/21.
//

public struct Player: Actor {
    public var position: Float2
    public var velocity: Float2
    public let radius: Float = 0.25
    public let speed: Float = 2
    public var direction: Float2
    public var direction3d: Float4x4
    public let turningSpeed: Float = .pi/2
    public var health: Float

    // player animation
    public var state: PlayerState = .idle
    var animation: Animation = .wandIdle
    public let attackCooldown: Float = 0.2

    public init(position: Float2) {
        self.position = position
        self.velocity = Float2(0, 0)
        self.direction = Float2(1, 0)
        self.direction3d = Float4x4.rotateY(.pi/2)
        self.health = 100
    }
}

public enum PlayerState {
    case idle
    case firing
}

public extension Player {
    var isDead: Bool {
        health <= 0
    }

    mutating func update(with input: Input) {
        direction = direction.rotated(by: input.rotation)
        direction3d = direction3d * input.rotation3d
        velocity = direction * Float(input.speed) * speed

        switch state {
        case .idle:
            if input.isFiring {
                state = .firing
                animation = .wandFire
            }
        case .firing:
            if animation.time >= attackCooldown {
                state = .idle
                animation = .wandIdle
            }
        }
    }
}

extension Animation {
    static let wandIdle = Animation(frames: [
        .wand
    ], duration: 0)
    static let wandFire = Animation(frames: [
        .wandFiring1,
        .wandFiring2,
        .wandFiring3,
        .wandFiring4,
        .wand
    ], duration: 0.5)
}
