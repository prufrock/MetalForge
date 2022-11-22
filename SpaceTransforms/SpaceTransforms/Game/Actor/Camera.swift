//
//  Camera.swift
//  SpaceTransforms
//
//  Created by David Kanenwisher on 11/22/22.
//

import simd

struct Camera: Actor {
    var position: MF2 = MF2(space: .world, value: F2(0.0, 0.0))
    var position3d: MF3 = MF3(space: .world, value: F3(2.0, 2.0, -1.5))
    var model: BasicModels

    var color: Float3 = Float3(0.0, 1.0, 0.0)

    var modelToUpright:Float4x4 {
        get {
            Float4x4.scale(x: 0.01, y: 0.01, z: 0.0)
        }
    }

    var uprightToWorld:Float4x4 {
        get {
            Float4x4.translate(x: position.value.x, y: position.value.y, z: 0.0)
        }
    }

    func worldToView(fov: Float, aspect: Float, nearPlane: Float, farPlane: Float) -> Float4x4 {
        Float4x4.perspectiveProjection(fov: fov, aspect: aspect, nearPlane: nearPlane, farPlane: farPlane)
        * Float4x4.translate(x: position3d.value.x, y: position3d.value.y, z: position3d.value.z).inverse //invert because we look out of the camera
    }
}
