//
//  MFloat2.swift
//  SpaceTransforms
//
//  Created by David Kanenwisher on 11/15/22.
//

import Foundation
import simd

struct MFloat2 {
    let space: MSpaces
    var value: Float2

    static func +(left: MFloat2, right: Float2) -> MFloat2 {
        let v = left.value + right
        return MFloat2(space: left.space, value: v)
    }

    /**
     - Parameters:
       - camera:  The camera to convert the point through.
       - aspect: The aspect ratio of the screen to adjust the camera for.
     - Returns:
     */
    func toWorldSpace(camera: Camera, aspect: Float) -> MFloat2 {
        // Invert the Camera so that the position can go from NDC space to world space.
        // TODO need to share the camera values used by the renderer
        let ndc = Float4(position: self)
        let position4 = (camera.worldToView(fov: .pi/2, aspect: aspect, nearPlane: 0.1, farPlane: 20.0)).inverse * Float4(position: self)
        print("ndc world:", String(format: "%.8f, %.8f, %.8f, %.8f", ndc.x, ndc.y, ndc.z, ndc.w))
        print("click world:", String(format: "%.8f, %.8f, %.8f, %.8f", position4.x, position4.y, position4.z, position4.w))
        return MFloat2(space: .world, value: Float2(position4.x, position4.y))
    }

    /**
     - Parameters:
       - screenWidth: The width of the screen that corresponds with the coordinates.
       - screenHeight: The height of the screen that corresponds with the coordinates.
       - flipY: macOS has an origin in the lower left while iOS has the origin in the upper right so you need to flip y.
     - Returns:
     */
    func toNdcSpace(screenWidth: Float, screenHeight: Float, flipY: Bool = true) -> MFloat2 {
        // divide position.x by the screenWidth so number varies between 0 and 1
        // multiply that by 2 so that it varies between 0 and 2
        // subtract 1 because NDC x increases as you go to the right and this moves the value between -1 and 1.
        // remember the abs(-1 - 1) = 2 so multiplying by 2 is important
        let x = ((value.x / screenWidth) * 2) - 1
        // converting position.y is like converting position.x
        // multiply by -1 when flipY is set because on iOS the origin is in the upper left
        let y = (flipY ? -1 : 1) * (((value.y / screenHeight) * 2) - 1)
        print("click screen:", String(format: "%.8f, %.8f", value.x, value.y))
        print("click NDC:", String(format: "%.8f, %.8f", x, y))
        return MFloat2(space: .ndc, value: Float2(x, y))
    }
}

typealias MF2 = MFloat2

typealias Float2 = SIMD2<Float>
typealias F2 = Float2

extension Float2 {
    var length : Float {
        (x * x + y * y).squareRoot()
    }
}
