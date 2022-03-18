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

    public init(position: Float2) {
        self.position = position
    }

    mutating func update(in world: World) {
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
            let direction = world.player.position - position
            velocity = direction * (speed / direction.length)
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
}

enum MonsterState {
    case idle
    case chasing
}