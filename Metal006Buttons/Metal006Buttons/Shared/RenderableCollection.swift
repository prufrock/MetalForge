//
// Created by David Kanenwisher on 10/28/21.
//

import Foundation
import MetalKit

protocol RenderableCollection {
    func click(x: Float, y: Float) -> RenderableCollection

    func setCameraDimension(top: Float, bottom: Float) -> RenderableCollection

    func update(elapsed: Double) -> RenderableCollection

    func render(to: (RenderableNode) -> Void)

    func cameraSpace(withAspect aspect: Float) -> float4x4

    func setScreenDimensions(height: Float, width: Float) -> RenderableCollection
}
