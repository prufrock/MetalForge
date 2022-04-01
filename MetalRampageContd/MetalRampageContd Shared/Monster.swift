//
// Created by David Kanenwisher on 2/19/22.
//

public struct Monster: Actor {
    var position: Float2
    let radius: Float = 0.4375
    let speed: Float = 0.5
    var velocity: Float2 = Float2(x: 0, y: 0)
    var state: MonsterState = .idle
    var animation: Animation = .monsterIdle
    let attackCooldown: Float = 0.4
    private(set) var lastAttackTime: Float = 0

    public init(position: Float2) {
        self.position = position
    }

    mutating func update(in world: inout World) {
        switch state {
        case .idle:
            if canSeePlayer(in: world) {
                state = .chasing
                animation = .monsterWalk
            }
            velocity = Float2(x: 0, y: 0)
        case .chasing:
            guard canSeePlayer(in: world)  else {
                state = .idle
                animation = .monsterIdle
                break
            }
            if canReachPlayer(in: world) {
                state = .scratching
                animation = .monsterScratch
                lastAttackTime = -attackCooldown
            }
            let direction = world.player.position - position
            velocity = direction * (speed / direction.length)
        case .scratching:
            guard canReachPlayer(in: world) else {
                state = .chasing
                animation = .monsterWalk
                break
            }
            if animation.time - lastAttackTime >= attackCooldown {
                lastAttackTime = animation.time
                world.hurtPlayer(10)
            }
        }
    }
}

extension Monster {
    func canSeePlayer(in world: World) -> Bool {
        let direction = world.player.position - position
        let playerDistance = direction.length
        let ray = Ray(origin: position, direction: direction / playerDistance)
        let wallHit = world.map.hitTest(ray)
        let wallDistance = (wallHit - position).length
        return wallDistance > playerDistance
    }

    func canReachPlayer(in world: World) -> Bool {
        let reach: Float = 0.25
        let playerDistance = (world.player.position - position).length
        return playerDistance - radius - world.player.radius < reach
    }

    func billboard(for ray: Ray) -> Billboard {
        // Since the sprites all face the player, the plane of every sprite will be parallel to the view plane, which is itself orthogonal to the player's direction
        let plane = ray.direction.orthogonal
        return Billboard(
            start: position - plane / 2,
            direction: plane,
            length: 1,
            position: position,
            texture: animation.texture
        )
    }
}

enum MonsterState {
    case idle
    case chasing
    case scratching
}

extension Animation {
    static let monsterIdle = Animation(frames: [.monster], duration: 0)
    static let monsterWalk = Animation(frames: [.monsterWalk1, .monsterWalk2], duration: 0.5)
    static let monsterScratch = Animation(frames: [
        .monsterScratch1,
        .monsterScratch2,
        .monsterScratch3,
        .monsterScratch4,
        .monsterScratch5,
        .monsterScratch6,
        .monsterScratch7,
        .monsterScratch8,
    ], duration: 0.8)
}