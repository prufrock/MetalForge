//
// Created by David Kanenwisher on 12/20/21.
//

import simd

public struct World {
    public private(set) var map: Tilemap
    private(set) var doors: [Door]
    public private(set) var player: Player!
    public private(set) var monsters: [Monster]
    private(set) var pushWalls: [PushWall]
    private(set) var switches: [Switch]
    private(set) var effects: [Effect]
    private(set) var isLevelEnded: Bool
    var showMap: Bool = false
    var drawWorld: Bool = true

    public init(map: Tilemap) {
        self.map = map
        self.doors = []
        self.monsters = []
        self.effects = []
        self.pushWalls = []
        self.switches = []
        self.isLevelEnded = false
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

        //check for level end
        //do this early so nothing bad can happen to the player before the level ends
        //also, let the effects run to completion
        if isLevelEnded {
            if effects.isEmpty {
                //put the pieces back in place
                reset()
                //fade to black when the level ends
                effects.append(Effect(type: .fadeIn, color: ColorA(.black), duration: 0.5))
            }
            return
        }

        //update player
        if player.isDead, effects.isEmpty {
            reset()
            effects.append(Effect(type: .fadeIn, color: ColorA(.red, a: 1.0), duration: 0.5))
            return
        }

        if player.isDead == false {
            player = player.run {
                var updatedPlayer = $0

                updatedPlayer.animation.time += timeStep
                updatedPlayer.update(with: input, in: &self)

                // Is there way to move position changes into player.update()?
                updatedPlayer.position += player.velocity * timeStep
                updatedPlayer.position.x.formTruncatingRemainder(dividingBy: size.x - 1)
                updatedPlayer.position.y.formTruncatingRemainder(dividingBy: size.y - 1)

                return updatedPlayer
            }

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

        //update doors
        for i in 0 ..< doors.count {
            var door = doors[i]
            door.time += timeStep
            door.update(in: &self)
            doors[i] = door
        }

        //update push walls
        for i in 0 ..< pushWalls.count {
            var pushWall = pushWalls[i]
            pushWall.update(in: &self)
            pushWall.position += pushWall.velocity * timeStep
            pushWalls[i] = pushWall
        }

        //update switches
        for i in 0 ..< switches.count {
            var s = switches[i]
            s.animation.time += timeStep
            s.update(in: &self)
            switches[i] = s
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

            // Check for stuck actors
            if player.isStuck(in: self) {
                hurtPlayer(1)
            }
            for i in 0 ..< monsters.count where monsters[i].isStuck(in: self) {
                hurtMonster(at: i, damage: 1)
            }

            // check if the monster intersects with the world
            monster.avoidWalls(in: self)

            monsters[i] = monster
        }

        // check if the player intersects with the world
        player.avoidWalls(in: self)
    }

    mutating func hurtPlayer(_ damage: Float) {
        if player.isDead {
            return
        }

        effects.append(Effect(type: .fadeIn, color: ColorA(.red), duration: 0.2))
        player.health -= damage
        // putting this here to make sure the player doesn't keep moving if they die
        // Should there be a state change when they die?
        player.velocity = Float2(x: 0, y: 0)

        if player.isDead {
            effects.append(Effect(type: .fadeOut, color: ColorA(.red), duration: 2))
        }
    }

    /**
     Reduces the health of the monster at *index* by *damage*
     - Parameters:
       - index: Int
       - damage: Float
     */
    mutating func hurtMonster(at index: Int, damage: Float) {
        var monster = monsters[index]
        // you can't hurt what's already dead
        if monster.isDead {
            return
        }

        // Do the damage
        monster.health -= damage

        // Check to see if it's hurt or dead and respond accordingly
        if monster.isDead {
            monster.state = .dead
            monster.animation = .monsterDeath
            // change velocity when changing state
            monster.velocity = Float2(x: 0, y: 0)
        } else {
            monster.state = .hurt
            monster.animation = .monsterHurt
        }

        // Write the monster back to the world
        monsters[index] = monster
    }

    mutating func endLevel() {
        isLevelEnded = true
        effects.append(Effect(type: .fadeOut, color: ColorA(.black), duration: 2))
    }

    mutating func reset() {
        monsters = []
        doors = []
        switches = []
        isLevelEnded = false

        var pushWallCount = 0

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
                case .door:
                    // crash early if the door is on the map edge
                    precondition(y > 0 && y < map.height, "Door cannot be placed on map edge")
                    // if there is a wall above and below the door then it's vertical
                    let isVertical = map[x, y - 1].isWall && map[x, y + 1].isWall
                    doors.append(Door(
                        position: position,
                        isVertical: isVertical
                    ))
                case .pushWall:
                    // if we've already replace the walls with push walls just use tile from the existing push wall
                    // but reset it's position.
                    pushWallCount += 1
                    if pushWalls.count >= pushWallCount {
                        let tile = pushWalls[pushWallCount - 1].tile
                        pushWalls[pushWallCount - 1] = PushWall(position: position, tile: tile)
                        break
                    }
                    // take the tile from the map
                    var tile = map[x, y]
                    // if it's a wall replace it with a floor
                    if tile.isWall {
                        map[x, y] = map.closestFloorTile(to: x, y) ?? .floor
                    } else {
                        // if it's a floor use the default wall tile
                        tile = .wall
                    }
                    // now add a PushWall at the current position with the tile we agreed on
                    pushWalls.append(PushWall(position: position, tile: tile))
                case .switch:
                    precondition(map[x, y].isWall, "Switch must be placed on a wall tile")
                    switches.append(Switch(position: position))
                }
            }
        }
    }

    var sprites: [Billboard] {
        // The ray is used to make the billboard orthogonal to the player(or any ray)
        let ray = Ray(origin: player.position, direction: player.direction)
        // append billboards here to draw more sprites
        return monsters.map { $0.billboard(for: ray)} + doors.map { $0.billboard } + pushWalls.flatMap { $0.billboards }
    }

    func hitTest(_ ray: Ray) -> Float2 {
        // Figure out how far away the wall is from the origin of the ray.
        var wallHit = map.hitTest(ray)
        var distance = (wallHit - ray.origin).length

        let billboards = doors.map { $0.billboard } + pushWalls.flatMap { $0.billboards }
        // if we don't hit this billboard check the next one
        for billboard in billboards {
            guard let hit = billboard.hitTest(ray) else {
                continue
            }

            // if this door is closer than the last one use this door for the next iteration
            let hitDistance = (hit - ray.origin).length
            guard hitDistance < distance else {
                continue
            }
            wallHit = hit
            distance = hitDistance
        }

        return wallHit
    }

    /**
    Determines if and which monster was hit.
     - Parameter ray: Ray
     - Returns: Int?
     */
    func pickMonster(_ ray: Ray) -> Int? {
        // hit test to see if we hit a wall instead of a monster
        let wallHit = hitTest(ray)
        var distance = (wallHit - ray.origin).length

        var result: Int? = nil
        for i in monsters.indices {
            // If it didn't hit this monster check the next one.
            guard let hit = monsters[i].hitTest(ray) else {
                continue
            }
            let hitDistance = (hit - ray.origin).length

            // starting with the wall, if the new distance is closer than than the previous distance update the result
            // to the nearest hit monster(leave it nil if it's the wall). This way the index of the closest monster is
            // is returned or nil if a wall is hit.
            guard hitDistance < distance else {
                continue
            }
            result = i
            distance = hitDistance
        }
        return result
    }

    /**
     Check to see if the thing at x,y is a door.
     - Parameters:
       - x: Int
a       - y: Int
     - Returns:
     */
    func isDoor(at x: Int, _ y: Int) -> Bool {
        if ( x < 0 || y < 0 || x >= map.width || y >= map.height) {
            return false
        }
        // remember the things are held in a one dimensional array
        return map.things[y * map.width + x] == .door
    }

    /**
     Check to see if the thing at x,y is a switch
     - Parameters:
       - x: Int
       - y: Int
     - Returns: Bool
     */
    internal func `switch`(at x: Int, _ y: Int) -> Switch? {
        // make sure the switch is in things
        guard map.things[y * map.width + x] == .switch else {
            return nil
        }
        // if it is grab the object so we can access the texture
        return switches.first {
            Int($0.position.x) == x && Int($0.position.y) == y
        }
    }

    internal func wallTiles(at x: Int, _ y: Int) -> WallTiles {
        if let _ = `switch`(at: x, y) {
            return WallTiles(
                north: .wallSwitch,
                south: .wallSwitch,
                east: .wallSwitch,
                west: .wallSwitch
            )
        }


        return WallTiles(
            north: isDoor(at: x, y + 1) ? .doorJamb2 : map[x, y],
            south: isDoor(at: x, y - 1) ? .doorJamb2 : map[x, y],
            east: isDoor(at: x + 1, y) ? .doorJamb1 : map[x, y],
            west: isDoor(at: x - 1, y) ? .doorJamb1 : map[x, y]
        )
    }
}

struct WallTiles {
    let north: Tile
    let south: Tile
    let east: Tile
    let west: Tile
}
