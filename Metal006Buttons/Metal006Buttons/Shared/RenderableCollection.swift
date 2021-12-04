//
// Created by David Kanenwisher on 10/28/21.
//

import MetalKit

protocol RenderableCollection {
    func click(x: Float, y: Float) -> RenderableCollection

    func update(elapsed: Double) -> RenderableCollection

    func render(to: (RenderableNode) -> Void)

    func cameraSpace() -> Float4x4

    func setScreenDimensions(width: Float, height: Float) -> RenderableCollection
}
