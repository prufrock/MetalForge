//
// Created by David Kanenwisher on 11/29/21.
//

protocol CameraNode: GMSceneNode {
    var cameraTop: Float { get }
    var cameraBottom: Float { get }
    var transformation: float4x4 { get }
    var nearPlane: Float { get }

    func cameraSpace(withAspect aspect: Float) -> float4x4

    func projectionMatrix(_ aspect: Float) -> float4x4

    func reverseProjectionMatrix(_ aspect: Float) -> float4x4
}
