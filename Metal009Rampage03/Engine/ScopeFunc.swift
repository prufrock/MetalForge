//
// Created by David Kanenwisher on 2/9/22.
//

import Foundation

// I missed Kotlin's scope functions.
// https://gist.github.com/kakajika/0bb3fd14f4afd5e5c2ec
protocol ScopeFunc {}
extension ScopeFunc {
    // apply the following assignments to the object
    @inline(__always) func apply(block: (Self) -> ()) -> Self {
        block(self)
        return self
    }

    // and also do the following with the object
    @inline(__always) func also(block: (Self) -> ()) -> Self {
        block(self)
        return self
    }
}
extension NSObject: ScopeFunc {}
