//
// Created by David Kanenwisher on 2/19/22.
//

public struct GMMonster: GMActor {
    var position: Float2
    let radius: Float = 0.4375
    let speed: Float = 0.5
    var velocity: Float2 = Float2(x: 0, y: 0)
    var state: GMMonsterState = .idle
    var animation: GMAnimation = .monsterIdle
    let attackCooldown: Float = 0.4
    private(set) var lastAttackTime: Float = 0

    private(set) var path: [Float2] = []

    var health: Float = 50

    public init(position: Float2) {
        self.position = position
    }

    mutating func update(in world: inout GMWorld) {
        switch state {
        case .idle:
            if canSeePlayer(in: world) || canHearPlayer(in: world) {
                state = .chasing
                animation = .monsterWalk
                world.playSound(.monsterGroan, at: position)
            }
        case .chasing:
            // only scratch at the player if you can see them
            if canSeePlayer(in: world) || canHearPlayer(in: world) {
                // store the player's position for later chasing
                path = world.findPath(from: position, to: world.player.position)
                if canReachPlayer(in: world) {
                    state = .scratching
                    animation = .monsterScratch
                    lastAttackTime = -attackCooldown
                    // change velocity when changing state
                    velocity = Float2(x: 0, y: 0)
                }
            }
            // walk towards the last place the player was seen
            guard let destination = path.first else {
                break
            }
            let direction = destination - position

            let distance = direction.length
            // remove the node once it's reached
            if distance < 0.1 {
                path.removeFirst()
                break
            }
            velocity = direction * (speed / distance)
            // if the monster is blocked it stops for the length of monsterBlocked animation
            if world.monsters.contains(where: isBlocked(by:)) {
                state = .blocked
                animation = .monsterBlocked
                velocity = Float2(x: 0, y: 0)
            }
        case .scratching:
            guard canReachPlayer(in: world) else {
                state = .chasing
                animation = .monsterWalk
                break
            }
            if animation.time - lastAttackTime >= attackCooldown {
                lastAttackTime = animation.time
                world.hurtPlayer(10)
                world.playSound(.monsterSwipe, at: position)
            }
        case .hurt:
            if animation.isCompleted {
                state = .chasing
                animation = .monsterWalk
            }
        case .dead:
            if animation.isCompleted {
                animation = .monsterDead
            }
        case .blocked:
            // once blocked is done resume the chase
            if animation.isCompleted {
                state = .chasing
                animation = .monsterWalk
            }
        }
    }

    func isBlocked(by other: GMMonster) -> Bool {
        // if the other monster is dead or not chasing
        // push past it.
        if other.isDead || other.state != .chasing {
            return false
        }
        // ignore it if the other monster is too far way
        let direction = other.position - position
        let distance = direction.length
        if distance > radius + other.radius + 0.5 {
            return false
        }

        // direction / distance is the normalized direction
        // velocity / velocity.length is the normalized length
        // the dot product gives the cosine of the angle between them
        // 0.5 is a 120 degree arc in front of the monster
        // if the other monster is in that arc it's blocking
        return simd_dot(direction / distance, velocity / velocity.length) > 0.5
    }
}

extension GMMonster {
    var isDead: Bool { health <= 0 }

    func canSeePlayer(in world: GMWorld) -> Bool {
        // figure out the normalized direction to the player
        var direction = world.player.position - position
        let playerDistance = direction.length
        direction /= playerDistance

        let orthogonal = direction.orthogonal

        // fire two rays from the monster separated by 0.2 units from the monster's center
        // should mean that if you see the monster's eyes it sees you
        for offset in [-0.2, 0.2] {
            let origin = position + orthogonal * Float(offset)
            let ray = GMRay(origin: origin, direction: direction)
            let wallHit = world.hitTest(ray)
            let wallDistance = (wallHit - position).length
            if wallDistance > playerDistance {
                return true
            }
        }
        return false
    }

    func canHearPlayer(in world: GMWorld) -> Bool {
        // no need to check if the player isn't firing
        guard world.player.state == .firing else {
            return false
        }
        // make sure there are paths to the player
        // with in earshot
        return world.findPath(
            from: position,
            to: world.player.position,
            maxDistance: 12
        ).isEmpty == false
    }

    func canReachPlayer(in world: GMWorld) -> Bool {
        let reach: Float = 0.25
        let playerDistance = (world.player.position - position).length
        return playerDistance - radius - world.player.radius < reach
    }

    func billboard(for ray: GMRay) -> GMBillboard {
        // Since the sprites all face the player, the plane of every sprite will be parallel to the view plane, which is itself orthogonal to the player's direction
        let plane = ray.direction.orthogonal
        return GMBillboard(
            start: position - plane / 2,
            direction: plane,
            length: 1,
            position: position,
            texture: animation.texture
        )
    }

    /**
     Checks to see if the ray *hits* the monster's billboard. If it does it returns the position of the hit, otherwise
     nil.
     - Parameter ray: Ray
     - Returns: Float2?
     */
    func hitTest(_ ray: GMRay) -> Float2? {
        // if the monster is dead let the ray go through(don't get hit by attacks)
        guard isDead == false, let hit = billboard(for: ray).hitTest(ray) else {
            return nil
        }

        // Make sure the hit location is on the monster
        guard (hit - position).length < radius else {
            return nil
        }
        return hit
    }
}

enum GMMonsterState {
    case idle
    case chasing
    case blocked
    case scratching
    case hurt
    case dead
}

extension GMAnimation {
    static let monsterIdle = GMAnimation(frames: [
        .monster
    ], duration: 0)
    // if blocked pause for a moment by using the animation time
    static let monsterBlocked = GMAnimation(frames: [
        .monster
    ], duration: 1)
    static let monsterWalk = GMAnimation(frames: [.monsterWalk1, .monsterWalk2], duration: 0.5)
    static let monsterScratch = GMAnimation(frames: [
        .monsterScratch1,
        .monsterScratch2,
        .monsterScratch3,
        .monsterScratch4,
        .monsterScratch5,
        .monsterScratch6,
        .monsterScratch7,
        .monsterScratch8,
    ], duration: 0.8)
    static let monsterHurt = GMAnimation(frames: [
        .monsterHurt
    ], duration: 0.2)
    static let monsterDeath = GMAnimation(frames: [
        .monsterHurt,
        .monsterDeath1,
        .monsterDeath2
    ], duration: 0.5)
    static let monsterDead = GMAnimation(frames: [
        .monsterDead
    ], duration: 0)
}