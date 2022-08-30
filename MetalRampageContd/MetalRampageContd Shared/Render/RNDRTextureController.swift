//
// Created by David Kanenwisher on 8/28/22.
//

/**
 Determines the texture to use for a given GMActor.
 */
struct RNDRTextureController {
    let textures: [GMTextureType:RNDRComposedTexture]

    func textureFor(textureType: GMTextureType) -> RNDRTextureDescriptor {
        textures[textureType]!.compose()
    }
}

/**
 Knows all the properties of a texture so it can be rendered for a GMActor.
 */
protocol RNDRComposedTexture {
    func compose() -> RNDRTextureDescriptor
}

/**
 Knows the properties of a GMMonster
 */
struct RNDRMonsterComposer: RNDRComposedTexture {
    func compose() -> RNDRTextureDescriptor {
        let spriteSheet = SpriteSheet(textureWidth: 128, textureHeight: 32, spriteWidth: 16, spriteHeight: 16)

        return RNDRTextureDescriptor(file: .monsterSpriteSheet, dimensions: spriteSheet)
    }
}

/**
 Describes a texture.
 */
struct RNDRTextureDescriptor {
    let file: GMTexture
    let dimensions: SpriteSheet
}
