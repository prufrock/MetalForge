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

    // allow it to loop it's sound
    public let soundChannel: Int

    // player animation
    public var state: PlayerState = .idle
    var animation: Animation = .wandIdle
    public let attackCooldown: Float = 0.25

    public init(position: Float2, soundChannel: Int) {
        self.position = position
        self.velocity = Float2(0, 0)
        self.direction = Float2(1, 0)
        self.direction3d = Float4x4.rotateY(.pi/2)
        self.health = 100
        self.soundChannel = soundChannel
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

    // useful for sound effects
    var isMoving: Bool {
        velocity.x != 0 || velocity.y != 0
    }

    var canFire: Bool {
        switch state {
        // can fire when idle
        case .idle:
            return true

        // if firing you can fire again the time since last fired exceeds the attack cool down. The animation time is
        // used as a way to determine how much time has passed since last fired.
        case .firing:
            return animation.time >= attackCooldown
        }
    }

    /**
     Updates the player's state and direction via *input* and allows them to act on the *world*.
     - Parameters:
       - input: Input
       - world: World
     */
    mutating func update(with input: Input, in world: inout World) {
        // like in push wall allows `update` to determine the moment when the player starts or stops moving.
        let wasMoving = isMoving

        direction = direction.rotated(by: input.rotation)
        direction3d = direction3d * input.rotation3d
        velocity = direction * Float(input.speed) * speed

        // you can keep firing as long as you *canFire*
        if input.isFiring, canFire {
            state = .firing
            animation = .wandFire
            // make the sound at the player's position
            world.playSound(.castSpell, at: position)
            let ray = Ray(origin: position, direction: direction)
            if let index = world.pickMonster(ray) {
                world.hurtMonster(at: index, damage: 10)
                // make the sound at the monter's position
                world.playSound(.fireSpellHit, at: world.monsters[index].position)
            } else {
                // make the sound at place on the wall where hit happens
                let hitPosition = world.hitTest(ray)
                world.playSound(.spellMiss, at: hitPosition)
            }
        }

        switch state {
        case .idle:
            break
        case .firing:
            // you are no longer firing when the firing animation finishes
            if animation.isCompleted {
                state = .idle
                animation = .wandIdle
            }
        }

        if isMoving, !wasMoving {
            world.playSound(.playerWalk, at: position, in: soundChannel)
        } else if !isMoving {
            // stop playing the sound
            world.playSound(nil, at: position, in: soundChannel)
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
