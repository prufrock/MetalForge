//
// Created by David Kanenwisher on 10/28/21.
//

import Foundation
import MetalKit

protocol RenderableCollection {
    func click() -> RenderableCollection

    func click(x: CGFloat, y: CGFloat) -> RenderableCollection

    func setCameraDimension(top: GMFloat, bottom: GMFloat) -> RenderableCollection

    func update(elapsed: Double) -> RenderableCollection

    func render(to: (RenderableNode) -> Void)

    func cameraSpace(withAspect aspect: GMFloat) -> float4x4

    func setScreenDimensions(height: CGFloat, width: CGFloat) -> RenderableCollection
}
