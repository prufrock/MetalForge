//
// Created by David Kanenwisher on 10/28/21.
//

import Foundation

protocol RenderableCollection {
    func click() -> RenderableCollection

    func setCameraDimension(top: Float, bottom: Float) -> RenderableCollection

    func update(elapsed: Double) -> RenderableCollection

    func render(to: (RenderableNode) -> Void)
}
