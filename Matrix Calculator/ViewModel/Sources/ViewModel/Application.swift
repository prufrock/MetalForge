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

    class Builder {
        public let id: UUID = UUID()
        private var elements: [Button] = []

        public func create() -> Application {
            Application(
                id: UUID(),
                elements: elements
            )
        }

        public func element(element: Button) {
            elements.append(element)
        }
    }
}

func application(id: UUID, using lambda: (Application.Builder) -> Void) -> Application.Builder {
    let builder = Application.Builder();
    lambda(builder)
    return builder
}