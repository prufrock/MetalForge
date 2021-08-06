//
// Created by David Kanenwisher on 8/1/21.
//

import Foundation

/**
 Represents the entire application being presented.
 */
public struct Application {
    public let id: UUID
    private var elements: [Button]

    public init(
            id: UUID,
            elements: [Button]
    ) {
        self.id = id
        self.elements = elements
    }

    public init (
            id: UUID,
            @Builder _ builder: () -> [Button]
    ) {
        self.id = id
        self.elements = builder()
    }

    public func getElement(i: Int) -> Button { elements[i] }
    public func setElement(i: Int, element: Button) -> Application {
        Application(id: id, elements: elements.replace(index: 0, with: element))
    }

    @resultBuilder
    public class Builder {
        public static func buildBlock(_ components: Button...) -> [Button] {
            components.flatMap { [$0] }
        }
        private var id: UUID = UUID()
        private var elements: [Button] = []
    }
}
