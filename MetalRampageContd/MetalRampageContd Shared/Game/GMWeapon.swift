//
// Created by David Kanenwisher on 4/16/22.
//

enum GMWeapon {
    case wand
    case fireBlast
}

extension GMWeapon {
    struct Attributes {
        let idleAnimation: GMAnimation
        let fireAnimation: GMAnimation
        let fireSound: SoundName
        let damage: Float
        let coolDown: Float
        // the number of projectiles fired
        let projectiles: Int
        // the length of the arc the projects are spread over
        let spread: Float
        // the amount of charges the spell starts with
        let defaultCharges: Float
        // the icon to use on the HUD
        let hudIcon: GMTexture
    }

    var attributes: Attributes {
        switch self {
        case .wand:
            return Attributes(
                idleAnimation: .wandIdle,
                fireAnimation: .wandFire,
                fireSound: .castSpell,
                damage: 10,
                coolDown: 0.25,
                projectiles: 1,
                spread: 0,
                defaultCharges: .infinity,
                hudIcon: .wandIcon
            )
        case .fireBlast:
            return Attributes(
                idleAnimation: .fireBlastIdle,
                fireAnimation: .fireBlastFire,
                fireSound: .castFireSpell,
                damage: 50,
                coolDown: 0.5,
                projectiles: 5,
                spread: 0.4,
                defaultCharges: 5,
                hudIcon: .fireBlastIcon
            )
        }
    }
}

// Manage the weapon animations
extension GMAnimation {
    static let wandIdle = GMAnimation(frames: [
        .wand
    ], duration: 0)
    static let wandFire = GMAnimation(frames: [
        .wandFiring1,
        .wandFiring2,
        .wandFiring3,
        .wandFiring4,
        .wand
    ], duration: 0.5)
    static let fireBlastIdle = GMAnimation(frames: [
        .fireBlastIdle
    ], duration: 0)
    static let fireBlastFire = GMAnimation(frames: [
        .fireBlastFire1,
        .fireBlastFire2,
        .fireBlastFire3,
        .fireBlastFire4,
        .fireBlastIdle
    ], duration: 0.5)
}
