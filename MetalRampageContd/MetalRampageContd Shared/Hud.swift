//
// Created by David Kanenwisher on 5/5/22.
//

struct Hud {
    let healthString: String
    let healthTint: ColorA
    let chargesString: String
    let playerWeapon: Texture
    let weaponIcon: Texture

    init(player: Player) {
        let health = Int(max(0, player.health))
        switch health {
        case ...10:
            self.healthTint = ColorA(.red)
        case 10 ... 30:
            self.healthTint = ColorA(.yellow)
        default:
            self.healthTint = ColorA(.green)
        }
        self.healthString = String(health)
        self.chargesString = String(Int(max(0, min(99, player.charges))))
        self.playerWeapon = player.animation.texture
        self.weaponIcon = player.weapon.attributes.hudIcon
    }
}