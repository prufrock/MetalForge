//
// Created by David Kanenwisher on 11/29/21.
//

import Foundation

protocol GMSceneNode: RenderableNode {
    var children: [GMSceneNode] { get }

    func add(child: GMSceneNode) -> GMSceneNode

    func delete(child: GMSceneNode) -> GMSceneNode

    func update(transform: (GMSceneNode) -> GMSceneNode) -> GMSceneNode

    func setColor(_ color: float4) -> GMSceneNode

    func setChildren(_ children: [GMSceneNode]) -> GMSceneNode

    func move(elapsed: Double) -> GMSceneNode

    func render(to: (RenderableNode) -> Void)

    func translate(_ transform: float4x4) -> GMSceneNode
}