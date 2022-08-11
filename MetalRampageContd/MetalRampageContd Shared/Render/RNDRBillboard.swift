//
//  RNDRBillboard.swift
//  MetalRampageContd
//
//  Created by David Kanenwisher on 8/10/22.
//

struct RNDRBillboard {
    var direction: Float2
    var position: Float2
    var texture: GMTexture //TODO RNDRTexture
    var animationFrame: Int

    init(direction: Float2, position: Float2, texture: GMTexture, animationFrame: Int) {
        self.direction = direction
        self.position = position
        self.texture = texture
        self.animationFrame = animationFrame
    }

    static func from(monster: GMMonster, direction: Float2) -> RNDRBillboard {

        let animationFrame: Int
        switch monster.animation.texture {
            case .monster:
                animationFrame = 0
            case .monsterWalk1:
                animationFrame = 1
            case .monsterWalk2:
                animationFrame = 2
            case .monsterScratch1:
                animationFrame = 3
            case .monsterScratch2:
                animationFrame = 4
            case .monsterScratch3:
                animationFrame = 5
            case .monsterScratch4:
                animationFrame = 6
            case .monsterScratch5:
                animationFrame = 7
            case .monsterScratch6:
                animationFrame = 8
            case .monsterScratch7:
                animationFrame = 9
            case .monsterScratch8:
                animationFrame = 10
            case .monsterHurt:
                animationFrame = 11
            case .monsterDeath1:
                animationFrame = 12
            case .monsterDeath2:
                animationFrame = 13
            case .monsterDead:
                animationFrame = 14
            default:
                animationFrame = 0
        }

        return RNDRBillboard(
            direction: direction,
            position: monster.position,
            texture: .monsterSpriteSheet,
            animationFrame: animationFrame
        )
    }
}