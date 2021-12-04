//
// Created by David Kanenwisher on 11/29/21.
//

protocol GMCameraNode: GMNode {
    var cameraTop: Float { get }
    var cameraBottom: Float { get }
    var transformation: Float4x4 { get }
    var nearPlane: Float { get }
    var aspectRatio: Float { get }

    func cameraSpace() -> Float4x4

    func projectionMatrix() -> Float4x4

    func reverseProjectionMatrix() -> Float4x4
}
