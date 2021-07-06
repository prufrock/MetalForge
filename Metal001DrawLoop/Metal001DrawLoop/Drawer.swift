//
// Created by David Kanenwisher on 7/5/21.
//

import Foundation
import MetalKit

class Drawer: NSObject {
    let view: MTKView

    init(view: MTKView) {
        self.view = view

        super.init()

        view.delegate = self

        mtkView(view, drawableSizeWillChange: view.bounds.size)
    }

    class Builder {
        var view: MTKView?

        func build() -> Drawer {
            guard let view = view else {
                fatalError("""
                           Shoot, you forgot to give me a MTKView. I can't build your view now! Crashing...KAPOW!
                           """)
            }

            return Drawer(view: view)
        }
    }
}

extension Drawer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print(#function)
    }

    func draw(in view: MTKView) {
        print(#function)
    }
}