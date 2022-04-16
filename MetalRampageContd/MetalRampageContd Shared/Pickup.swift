//
//  Pickup.swift
//  MetalRampageContd
//
//  Created by David Kanenwisher on 4/15/22.
//

struct Pickup: Actor {
    var position: Float2
    let type: PickupType
    let radius: Float = 0.4

    init(type: PickupType, position: Float2) {
        self.type = type
        self.position = position
    }
}

extension Pickup {
    // You can't kill a pickup
    var isDead: Bool { return false }

    var texture: Texture {
        switch type {
        case .healingPotion:
            return .healingPotion
        }
    }

    func billboard(for ray: Ray) -> Billboard {
        // the billboard should be orthogonal to the ray
        // the ray comes from the player in the case
        // so the billboard is orthogonal to the player
        let plane = ray.direction.orthogonal
        return Billboard(
            start: position - plane / 2,
            direction: plane,
            length: 1,
            position: position,
            texture: texture
        )
    }
}

enum PickupType {
    case healingPotion
}
