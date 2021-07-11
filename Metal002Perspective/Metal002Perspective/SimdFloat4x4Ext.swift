//
// Created by David Kanenwisher on 7/8/21.
//

import simd

extension float4x4 {
    static func scaleX(_ scalar: Float) -> float4x4 {
        float4x4(
                [scalar, 0, 0, 0],
                [0, 1, 0, 0],
                [0, 0, 1, 0],
                [0, 0, 0, 1]
        )
    }

    // It mostly works. I had to discover what column major vs row major means so for a bit I had my columns all mixed
    // up. The near plane doesn't seem quite right yet for some reason because I pretty much just set "nearPlane" to 1
    // otherwise things get really small. This make sense, in a way, because I am effectively scaling them down. Also,
    // unless I'm mistaken about something it doesn't seem like my objects are all sharing a vanishing point. Instead
    // they all seem to have the same vanishing point at the center of each object. I must need to do a transformation
    // to move the objects into world space and maybe even camera space. I figured if I used NDC coordinates for the
    // vertices this wouldn't matter. It seems like the math doesn't quite work out that way though.
    static func perspectiveProjection(nearPlane: Float) -> float4x4 {
        float4x4(
                [nearPlane, 0, 0, 0],
                [0, nearPlane, 0, 0],
                [0, 0, 1, 1],
                [0, 0, 0, 1]
        )
    }

    static func translate(x: Float, y: Float, z: Float) -> float4x4 {
        float4x4(
                [1, 0, 0, 0],
                [0, 1, 0, 0],
                [0, 0, 1, 0],
                [x, y, z, 1]
        )
    }
}
