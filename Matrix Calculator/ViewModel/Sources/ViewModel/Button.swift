//
//  File.swift
//  
//
//  Created by David Kanenwisher on 8/1/21.
//

import Foundation

public struct Button {
    private let ID: UUID = UUID()
    private let disabled = true

    public init() {

    }

    public func isDisabled() -> Bool {
        disabled
    }
}
