//
// Created by David Kanenwisher on 7/5/21.
//

import Foundation
import MetalKit

class Drawer: NSObject {
    let view: MTKView

    init(view: MTKView) {
        self.view = view

        // Initialize NSObject so it can do what it needs to do.
        super.init()

        // Set the Drawer to the view delegate. Make sure the Drawer is fully initialized before doing this since
        // the object has now escaped. The fact that the objects escapes at this point makes me wonder if this isn't
        // the best place to do this. It seems a bit sneaky if you're trying to understand the threading model if
        // the an object escapes during the initializer.
        view.delegate = self

        // Call mtkView to set the initial size of the viewport. More happens here later.
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