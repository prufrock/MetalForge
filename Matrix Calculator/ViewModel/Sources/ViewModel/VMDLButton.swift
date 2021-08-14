//
//  File.swift
//  
//
//  Created by David Kanenwisher on 8/1/21.
//

import Foundation

public struct VMDLButton {
    private let id: UUID
    private let disabled: Bool

    public init(id: UUID, disabled: Bool) {
        self.id = id
        self.disabled = disabled
    }

    public func isDisabled() -> Bool {
        disabled
    }

    public func toggle() -> VMDLButton {
        VMDLButton(id: self.id, disabled: !disabled)
    }

    public func enable() -> VMDLButton {
        VMDLButton(id: self.id, disabled: false)
    }

    public func disable() -> VMDLButton {
        VMDLButton(id: self.id, disabled: true)
    }
}
