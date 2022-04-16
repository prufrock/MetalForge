//
// Created by David Kanenwisher on 4/16/22.
//

enum Weapon {
    case wand
    case fireBlast
}

extension Weapon {
    struct Attributes {
        let idleAnimation: Animation
        let fireAnimation: Animation
        let fireSound: SoundName
        let damage: Float
        let coolDown: Float
    }

    var attributes: Attributes {
        switch self {
        case .wand:
            return Attributes(
                idleAnimation: .wandIdle,
                fireAnimation: .wandFire,
                fireSound: .castSpell,
                damage: 10,
                coolDown: 0.25
            )
        case .fireBlast:
            return Attributes(
                idleAnimation: .fireBlastIdle,
                fireAnimation: .fireBlastFire,
                fireSound: .castFireSpell,
                damage: 50,
                coolDown: 0.5
            )
        }
    }
}

// Manage the weapon animations
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
    static let fireBlastIdle = Animation(frames: [
        .fireBlastIdle
    ], duration: 0)
    static let fireBlastFire = Animation(frames: [
        .fireBlastFire1,
        .fireBlastFire2,
        .fireBlastFire3,
        .fireBlastFire4,
        .fireBlastIdle
    ], duration: 0.5)
}
