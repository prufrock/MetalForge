//
// Created by David Kanenwisher on 10/28/21.
//

import Foundation
import MetalKit

protocol RenderableCollection {
    func click() -> RenderableCollection

    func setCameraDimension(top: Float, bottom: Float) -> RenderableCollection

    func update(elapsed: Double) -> RenderableCollection

    func render(to: (RenderableNode) -> Void)

    func cameraSpace(withAspect aspect: Float) -> float4x4

    func setScreenDimensions(height: CGFloat, width: CGFloat) -> RenderableCollection
}
