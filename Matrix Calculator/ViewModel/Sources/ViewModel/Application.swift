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

    public func getElement(i: Int) -> Button { elements[i] }
    public func setElement(i: Int, element: Button) -> Application {
        // TODO move to array extension
        let newElements = Array(elements[0 ..< i]) + [element] + Array(elements[(i+1) ..< (elements.count)])
        return Application(id: id, elements: newElements)
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