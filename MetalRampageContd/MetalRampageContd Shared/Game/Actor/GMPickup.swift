//
//  Pickup.swift
//  MetalRampageContd
//
//  Created by David Kanenwisher on 4/15/22.
//

struct GMPickup: GMActor {
    var position: Float2
    let type: GMPickupType
    let radius: Float = 0.4

    init(type: GMPickupType, position: Float2) {
        self.type = type
        self.position = position
    }
}

extension GMPickup {
    // You can't kill a pickup
    var isDead: Bool { return false }

    var texture: GMTexture {
        switch type {
        case .healingPotion:
            return .healingPotion
        case .fireBlast:
            return .fireBlastPickup
        }
    }

    private var textureId: UInt32 {
        var textureId: UInt32
        switch type {
        case .healingPotion:
            return 0
        case .fireBlast:
            return 1
        }
    }

    func billboard(for ray: GMRay) -> GMBillboard {
        // the billboard should be orthogonal to the ray
        // the ray comes from the player in the case
        // so the billboard is orthogonal to the player
        let plane = ray.direction.orthogonal
        return GMBillboard(
            start: position - plane / 2,
            direction: plane,
            length: 1,
            position: position,
            textureType: .pickup,
            textureId: textureId,
            textureVariant: .none
        )
    }
}

enum GMPickupType {
    case healingPotion
    case fireBlast
}
