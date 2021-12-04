//
// Created by David Kanenwisher on 11/29/21.
//

protocol GMCameraNode: GMNode {
    var cameraTop: Float { get }
    var cameraBottom: Float { get }
    var transformation: Float4x4 { get }
    var nearPlane: Float { get }

    func cameraSpace(withAspect aspect: Float) -> Float4x4

    func projectionMatrix(_ aspect: Float) -> Float4x4

    func reverseProjectionMatrix(_ aspect: Float) -> Float4x4
}
