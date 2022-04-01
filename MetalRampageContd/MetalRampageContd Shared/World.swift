//
// Created by David Kanenwisher on 12/20/21.
//

import simd

public struct World {
    public let map: Tilemap
    public private(set) var player: Player!
    public private(set) var monsters: [Monster]
    private(set) var effects: [Effect]
    var showMap: Bool = false
    var drawWorld: Bool = true

    public init(map: Tilemap) {
        self.map = map
        self.monsters = []
        self.effects = []
        reset()
    }
}

public extension World {
    var size: Float2 { map.size }

    mutating func update(timeStep: Float, input: Input) {
        //update effects
        effects = effects.compactMap { effect  in
            if effect.isCompleted {
                return nil
            }
            var effect = effect
            effect.time += timeStep
            return effect
        }

        //update player
        if player.isDead, effects.isEmpty {
            reset()
            effects.append(Effect(type: .fadeIn, color: ColorA(.red, a: 1.0), duration: 0.5))
            return
        }

        if player.isDead == false {
            player.animation.time += timeStep
            player.update(with: input)

            player.position += player.velocity * timeStep
            player.position.x.formTruncatingRemainder(dividingBy: size.x - 1)
            player.position.y.formTruncatingRemainder(dividingBy: size.y - 1)
        } else if effects.isEmpty {
            reset()
            return
        }

        showMap = input.showMap
        drawWorld = input.drawWorld

        //update monsters
        for i in 0 ..< monsters.count {
            var monster = monsters[i]
            monster.position += monster.velocity * timeStep
            monster.animation.time += timeStep
            monster.update(in: &self)
            monsters[i] = monster
        }

        //handle collisions
        for i in monsters.indices {
            var monster = monsters[i]
            if let intersection = player.intersection(with: monster) {
                player.position -= intersection / 2
                monster.position += intersection / 2
            }

            for j in i + 1 ..< monsters.count {
                if let intersection = monster.intersection(with: monsters[j]) {
                    monster.position -= intersection / 2
                    monsters[j].position += intersection / 2
                }
            }

            while let intersection = monster.intersection(with: map) {
                monster.position -= intersection
            }

            monsters[i] = monster
        }


        while let intersection = player.intersection(with: map) {
            player.position -= intersection
        }
    }

    mutating func hurtPlayer(_ damage: Float) {
        if player.isDead {
            return
        }

        effects.append(Effect(type: .fadeIn, color: ColorA(.red), duration: 0.2))
        player.health -= damage

        if player.isDead {
            effects.append(Effect(type: .fadeOut, color: ColorA(.red), duration: 2))
        }
    }

    mutating func reset() {
        monsters = []
        for y in 0 ..< map.height {
            for x in 0 ..< map.width {
                let position = Float2(x: Float(x) + 0.5, y: Float(y) + 0.5) // in the center of the tile
                let thing = map.things[y * map.width + x]
                switch thing {
                case .nothing:
                    break
                case .player:
                    player = Player(position: position)
                case .monster:
                    monsters.append(Monster(position: position))
                }
            }
        }
    }

    var sprites: [Billboard] {
        // The ray is used to make the billboard orthogonal to the player(or any ray)
        let ray = Ray(origin: player.position, direction: player.direction)
        return monsters.map { $0.billboard(for: ray)}
    }
}
