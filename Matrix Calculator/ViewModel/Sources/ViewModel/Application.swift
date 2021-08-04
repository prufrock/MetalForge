//
// Created by David Kanenwisher on 8/1/21.
//

import Foundation

/**
 Represents the entire application being presented.
 */
public struct Application {
    public let id: UUID
    private let elements: [Button]

    public init(
            id: UUID,
            elements: [Button]
    ) {
        self.id = id
        self.elements = elements
    }

    public init (
            id: UUID,
            @Builder builder: () -> [Button]
    ) {
        self.id = id
        self.elements = builder()
    }

    @resultBuilder
    class Builder {
        static func buildBlock(_ components: Button...) -> [Button] {
            components.flatMap { [$0] }
        }
        private var id: UUID = UUID()
        private var elements: [Button] = []
    }
}