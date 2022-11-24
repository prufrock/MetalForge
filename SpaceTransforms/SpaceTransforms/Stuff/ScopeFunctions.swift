//
//  ScopeFunctions.swift
//  SpaceTransforms
//
//  Created by David Kanenwisher on 11/15/22.
//

import Foundation

// I missed Kotlin's scope functions.
// https://gist.github.com/kakajika/0bb3fd14f4afd5e5c2ec
protocol ScopeFunction {}
extension ScopeFunction {
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

    // run statements on an object where you need an expression
    // useful for updating structs in place without adding additional variables to the local scope
    @inline(__always) func run<T>(block: (Self) -> T) -> T {
        block(self)
    }
}
extension NSObject: ScopeFunction {}

extension Player: ScopeFunction {}
extension ClickLocation: ScopeFunction {}
