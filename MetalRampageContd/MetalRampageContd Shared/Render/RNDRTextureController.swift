//
// Created by David Kanenwisher on 8/28/22.
//

/**
 Determines the texture to use for a given GMActor.
 */
struct RNDRTextureController {
    private let textures: [String:RNDRComposedTexture]

    func textureFor(actor: GMActor) -> RNDRTextureDescriptor {
        switch actor {
        case let monster as GMMonster:
            return textures["monster"]!.compose(texture: monster.animation.texture)
        default:
            print("Don't have a texture for that.")
            return textures["healingPotion"]!.compose(texture: .healingPotion)
        }
    }
}

/**
 Knows all the properties of a texture so it can be rendered for a GMActor.
 */
protocol RNDRComposedTexture {
    func compose(texture: GMTexture) -> RNDRTextureDescriptor
}

/**
 Knows the properties of a GMMonster
 */
struct RNDRMonsterComposer: RNDRComposedTexture {
    func compose(texture: GMTexture) -> RNDRTextureDescriptor {
        let spriteSheet = SpriteSheet(textureWidth: 128, textureHeight: 32, spriteWidth: 16, spriteHeight: 16)

        // select the texture
        var textureId: UInt32
        switch texture {
        case .monster:
            textureId = 0
        case .monsterWalk1:
            textureId = 1
        case .monsterWalk2:
            textureId = 2
        case .monsterScratch1:
            textureId = 3
        case .monsterScratch2:
            textureId = 4
        case .monsterScratch3:
            textureId = 5
        case .monsterScratch4:
            textureId = 6
        case .monsterScratch5:
            textureId = 7
        case .monsterScratch6:
            textureId = 8
        case .monsterScratch7:
            textureId = 9
        case .monsterScratch8:
            textureId = 10
        case .monsterHurt:
            textureId = 11
        case .monsterDeath1:
            textureId = 12
        case .monsterDeath2:
            textureId = 13
        case .monsterDead:
            textureId = 14
        default:
            textureId = 0
        }

        return RNDRTextureDescriptor(file: .monsterSpriteSheet, dimensions: spriteSheet, textureId: textureId)
    }
}

/**
 Describes a texture.
 */
struct RNDRTextureDescriptor {
    let file: GMTexture
    let dimensions: SpriteSheet
    let textureId: UInt32
}
