//
// Created by David Kanenwisher on 12/16/21.
//

struct GMPlayer: GMActor {
    var position: Float2
    var velocity: Float2
    let radius: Float = 0.25
    let speed: Float = 2
    var direction: Float2
    var direction3d: Float4x4
    let turningSpeed: Float = .pi/2
    var health: Float

    // allow it to loop it's sound
    let soundChannel: Int

    // player animation
    var state: GMPlayerState = .idle
    var animation: GMAnimation

    // weapon/spell related
    private(set) var weapon: GMWeapon = .wand
    private(set) var charges: Float

    init(position: Float2, soundChannel: Int) {
        self.position = position
        self.velocity = Float2(0, 0)
        self.direction = Float2(1, 0)
        self.direction3d = Float4x4.rotateY(.pi/2)
        self.health = 100
        self.soundChannel = soundChannel
        self.animation = weapon.attributes.idleAnimation
        self.charges = weapon.attributes.defaultCharges
    }
}

enum GMPlayerState {
    case idle
    case firing
}

extension GMPlayer {
    var isDead: Bool {
        health <= 0
    }

    // useful for sound effects
    var isMoving: Bool {
        velocity.x != 0 || velocity.y != 0
    }

    var canFire: Bool {
        // can't cast if there aren't any charges
        guard charges > 0 else {
            return false
        }

        switch state {
        // can fire when idle
        case .idle:
            return true

        // if firing you can fire again the time since last fired exceeds the weapon cool down. The animation time is
        // used as a way to determine how much time has passed since last fired.
        case .firing:
            return animation.time >= weapon.attributes.coolDown
        }
    }

    internal mutating func setWeapon(_ weapon: GMWeapon) {
        self.weapon = weapon
        self.animation = weapon.attributes.idleAnimation
        self.charges = weapon.attributes.defaultCharges
    }

    // Used to pass properties to new player instances between levels
    internal mutating func inherit(from player: GMPlayer) {
        health = player.health
        setWeapon(player.weapon)
        charges = player.charges
    }

    /**
     Updates the player's state and direction via *input* and allows them to act on the *world*.
     - Parameters:
       - input: Input
       - world: World
       - buttonClicked: Bool whether or not a button was clicked. Prevents the firing of the weapon.
     */
    mutating func update(with input: GMInput, in world: inout GMWorld, buttonClicked: Bool) {
        // like in push wall allows `update` to determine the moment when the player starts or stops moving.
        let wasMoving = isMoving

        direction = direction.rotated(by: input.rotation)
        direction3d = direction3d * input.rotation3d
        velocity = direction * Float(input.speed) * speed

        if buttonClicked {
            print("button clicked")
        }

        // you can keep firing as long as you *canFire*
        if input.isFiring, canFire, !buttonClicked {
            state = .firing
            // take away a charge after firing
            charges -= 1
            animation = weapon.attributes.fireAnimation
            // make the sound at the player's position
            world.playSound(weapon.attributes.fireSound, at: position)
            // fire a ray for each projectile
            let projectiles = weapon.attributes.projectiles

            // make it so the hit and impact sounds play at most once by storing one for each
            // and then playing the sound after it's calculated
            var hitPosition, missPosition: Float2?
            for _ in 0 ..< projectiles {

                // calculate how the projectiles randomly spread in front of the player
                let spread = weapon.attributes.spread
                let sine = Float.random(in: -spread ... spread)
                let cosine = (1 - sine * sine).squareRoot()
                let direction = self.direction.rotated(by: Float2x2.rotate(sine: sine, cosine: cosine))

                let ray = GMRay(origin: position, direction: direction)
                if let index = world.pickMonster(ray) {
                    // Divide the amount of damage by the number of projectiles
                    world.hurtMonster(at: index, damage: weapon.attributes.damage / Float(projectiles))
                    // make the sound at the monster's position
                    hitPosition = world.monsters[index].position
                } else {
                    // make the sound at place on the wall where hit happens
                    missPosition = world.hitTest(ray)
                }
            }

            // play the sounds no more than once
            if let hitPosition = hitPosition {
                world.playSound(.monsterHit, at: hitPosition)
            }
            if let missPosition = missPosition {
                world.playSound(.spellMiss, at: missPosition)
            }
        }

        switch state {
        case .idle:
            // when out of charges switch to default spell
            if charges == 0 {
                setWeapon(.wand)
            }
        case .firing:
            // you are no longer firing when the firing animation finishes
            if animation.isCompleted {
                state = .idle
                animation = weapon.attributes.idleAnimation
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

