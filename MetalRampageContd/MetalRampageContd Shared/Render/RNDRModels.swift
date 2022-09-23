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
        // The z-normals are causing an internal normal due to rotation...not sure how to remove this yet.
        // I'm going to skip them for now but I think I need to come back to them to light the ceiling and floor.
        // I suspect I'm just going to need to make a primitive cube.
        normals: [
//            Float3(-0.5, -0.5, 0.0),
            Float3(0.0, 0.0, -1.0), // 0

//            Float3(-0.5, -0.5, 0.0),
//            Float3(-0.5, -0.5, 1.0),

//            Float3(-0.5, 0.5, 0.0),
            Float3(0.0, 0.0, -1.0), // 1

//            Float3(-0.5, 0.5, 0.0),
//            Float3(-0.5, 0.5, 1.0),

//            Float3(0.5, 0.5, 0.0),
            Float3(0.0, 0.0, -1.0), // 2

            Float3(0.0, 0.0, -1.0), // 2

//            Float3(0.5, 0.5, 0.0),
//            Float3(0.5, 0.5, 1.0),

//            Float3(0.5, -0.5, 0.0),
            Float3(0.0, 0.0, -1.0), // 3

//            Float3(0.5, -0.5, 0.0),
//            Float3(0.5, -0.5, 1.0),

            Float3(0.0, 0.0, -1.0), // 0
        ]
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
