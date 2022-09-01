//
// Created by David Kanenwisher on 3/15/22.
//

import Metal

/**
 A simple struct that has what's needed to render an object.
 */
struct RNDRObject {
    let vertices: [Float3]
    let uv: [Float2]
    let transform: Float4x4
    let color: GMColor
    let primitiveType: MTLPrimitiveType
    let position: Int2 // I seem to have forgotten what this is for
    let texture: GMTexture? // not everything has a texture
    let textureType: GMTextureType? // not everything has a textureType
    let textureId: UInt32? // nor does everything have a textureId
    let textureVariant: GMTextureVariant? // still not even all things have a textureVariant

    init(vertices: [Float3],
         uv: [Float2],
         transform: Float4x4,
         color: GMColor,
         primitiveType: MTLPrimitiveType,
         position: Int2,
         texture: GMTexture? = .none,
         textureType: GMTextureType? = .none,
         textureId: UInt32? = 0,
         textureVariant: GMTextureVariant? = .none
    ) {
        self.vertices = vertices
        self.uv = uv
        self.transform = transform
        self.color = color
        self.primitiveType = primitiveType
        self.position = position
        self.texture = texture
        self.textureType = textureType
        self.textureId = textureId
        self.textureVariant = textureVariant
    }
}

extension RNDRObject {
    func toTuple() -> ([Float3], [Float2], Float4x4, GMColor, MTLPrimitiveType, GMTexture?) {
        (vertices, uv, transform, color, primitiveType, texture)
    }
}

/**
This extension is in here because it necessary for rendering not for any aspect of game
It also has a dependency on Metal.
 */
extension GMBillboard {

    /**
    Converts a GMBillboard to RNDRObject with the provided model as the target.
     - Parameter model: RNDRModel the model to render
     - Returns: RNDRObject a representation of the billboard for drawing
     */
    func toRNDRObject(with model: RNDRModel) -> RNDRObject {
        RNDRObject(
            vertices: model.vertices,
            uv: model.uv,
            transform: Float4x4.identity()
                * Float4x4.translate(x: Float(position.x), y: Float(position.y), z: 0.5)
                * (Float4x4.identity()
                * Float4x4.rotateX(-(3 * .pi)/2)
                // use atan2 to convert the direction vector to an angle
                // this works because these sprites only rotate about the y axis.
                * Float4x4.rotateY(atan2(direction.y, direction.x))),
            color: GMColor.black,
            primitiveType: MTLPrimitiveType.triangle,
            position: Int2(),
            texture: texture,
            textureType: textureType,
            textureId: textureId,
            textureVariant: textureVariant
        )
    }
}
