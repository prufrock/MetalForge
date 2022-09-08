//
// Created by David Kanenwisher on 8/28/22.
//

/**
 Determines the texture to use for a given GMActor.
 */
struct RNDRTextureController {
    let textures: [GMTextureType:RNDRComposedTexture]

    func textureFor(textureType: GMTextureType, variant: GMTextureVariant) -> RNDRTextureDescriptor {
        textures[textureType]!.compose(variant: variant)
    }
}

/**
 Knows all the properties of a texture so it can be rendered for a GMActor.
 */
protocol RNDRComposedTexture {
    func compose(variant: GMTextureVariant) -> RNDRTextureDescriptor
}

/**
 Knows the properties of a GMMonster
 */
struct RNDRMonsterComposer: RNDRComposedTexture {
    func compose(variant: GMTextureVariant) -> RNDRTextureDescriptor {
        let spriteSheet = SpriteSheet(textureWidth: 128, textureHeight: 32, spriteWidth: 16, spriteHeight: 16)

        switch variant {
        case .monsterBlob:
            return RNDRTextureDescriptor(file: .monsterBlobSpriteSheet, dimensions: spriteSheet)
        default:
            return RNDRTextureDescriptor(file: .monsterSpriteSheet, dimensions: spriteSheet)
        }
    }
}

struct RNDRDoorComposer: RNDRComposedTexture {
    func compose(variant: GMTextureVariant) -> RNDRTextureDescriptor {
        let spriteSheet = SpriteSheet(textureWidth: 32, textureHeight: 16, spriteWidth: 16, spriteHeight: 16)

        switch variant {
        default:
            return RNDRTextureDescriptor(file: .doorSpriteSheet, dimensions: spriteSheet)
        }
    }
}

/**
 Describes a texture.
 */
struct RNDRTextureDescriptor {
    let file: GMTexture
    let dimensions: SpriteSheet
}
