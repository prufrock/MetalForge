//
//  RNDRModels.swift
//  MetalRampageContd
//
//  Created by David Kanenwisher on 6/17/22.
//


func unitSquare() -> RNDRModel {
    RNDRModel(
        vertices: [
            Float3(-0.5, -0.5, 0.0),
            Float3(-0.5, 0.5, 0.0),
            Float3(0.5, 0.5, 0.0),
            Float3(0.5, -0.5, 0.0),
        ],
        uv: [
            Float2(0.0, 1.0),
            Float2(0.0 ,0.0),
            Float2(1.0, 0.0),
            Float2(1.0, 1.0),
        ],
        index: [0, 1, 2, 2, 3, 0],
        // I might have hit on something when trying to get the wand to light properly.
        // I don't think the normals are getting rotated fully because when I use this with the world transforms
        // and set the z to 1.0 on the normals the floor is fully lit all the time and everything else is dark!
        normals: (0...5).map { _ in Float3(0.0, 0.0, -1.0) }
    )
}

// Sitting with its bottom center on the origin
func lineCube(_ transformation: Float4x4 = Float4x4.identity()) -> [RNDRObject] {
    return [
        RNDRObject(
            // xy z-0.5
            vertices: [
                Float3(-0.5, 0.0, -0.5),
                Float3(-0.5, 1.0, -0.5),

                Float3(-0.5, 1.0, -0.5),
                Float3(0.5, 1.0, -0.5),

                Float3(0.5, 1.0, -0.5),
                Float3(0.5, 0.0, -0.5),

                Float3(0.5, 0.0, -0.5),
                Float3(-0.5, 0.0, -0.5),
            ], uv: [],
            transform: transformation,
            color: .green,
            primitiveType: .line,
            position: Int2(),
            texture: nil
        ),
        RNDRObject(
            // xy z1
            vertices: [
                Float3(-0.5, 0.0, 0.5),
                Float3(-0.5, 1.0, 0.5),

                Float3(-0.5, 1.0, 0.5),
                Float3(0.5, 1.0, 0.5),

                Float3(0.5, 1.0, 0.5),
                Float3(0.5, 0.0, 0.5),

                Float3(0.5, 0.0, 0.5),
                Float3(-0.5, 0.0, 0.5),
            ], uv: [],
            transform: transformation,
            color: .green,
            primitiveType: .line,
            position: Int2(),
            texture: nil
        ),
        RNDRObject(
            //xz y0
            vertices: [
                Float3(-0.5, 0.0, -0.5),
                Float3(-0.5, 0.0, 0.5),

                Float3(-0.5, 0.0, 0.5),
                Float3(0.5, 0.0, 0.5),

                Float3(0.5, 0.0, 0.5),
                Float3(0.5, 0.0, -0.5),

                Float3(0.5, 0.0, -0.5),
                Float3(-0.5, 0.0, -0.5),
            ], uv: [],
            transform: transformation,
            color: .green,
            primitiveType: .line,
            position: Int2(),
            texture: nil
        ),
        RNDRObject(
            //xz y1
            vertices: [
                Float3(-0.5, 1.0, -0.5),
                Float3(-0.5, 1.0, 0.5),

                Float3(-0.5, 1.0, 0.5),
                Float3(0.5, 1.0, 0.5),

                Float3(0.5, 1.0, 0.5),
                Float3(0.5, 1.0, -0.5),

                Float3(0.5, 1.0, -0.5),
                Float3(-0.5, 1.0, -0.5),
            ], uv: [],
            transform: transformation,
            color: .green,
            primitiveType: .line,
            position: Int2 (),
            texture: nil
        )
    ]
}
