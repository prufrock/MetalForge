//
//  File.swift
//  
//
//  Created by David Kanenwisher on 8/1/21.
//

import Foundation

public struct Button {
    private let id: UUID
    private let disabled: Bool

    public init(id: UUID, disabled: Bool) {
        self.id = id
        self.disabled = disabled
    }

    public func isDisabled() -> Bool {
        disabled
    }

    public func toggle() -> Button {
        Button(id: self.id, disabled: !disabled)
    }

    public func enable() -> Button {
        Button(id: self.id, disabled: false)
    }

    public func disable() -> Button {
        Button(id: self.id, disabled: true)
    }
}
