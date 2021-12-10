//
// Created by David Kanenwisher on 12/10/21.
//

import Foundation

struct GMImmutableContainerNode<Element: Equatable>: Equatable {
    private let children: [Self]

    var count: Int {
        get {
            var count = 0

            count = count + children.count

            children.forEach { node in
                count = count + node.count
            }

            return count
        }
    }

    public let element: Element

    init(children: [Self], element: Element) {
        self.children = children
        self.element = element
    }

    func add(child: Self) -> Self {
        clone(
            children: children + [child]
        )
    }

    func remove(child: Self) -> Self {
        for i in 0..<children.count {
            if (children[i] == child) {
                var newChildren = children
                newChildren.remove(at: i)
                return clone(children: newChildren)
            } else {
                var newChildren = children
                newChildren[i] = newChildren[i].remove(child: child)
                return clone(
                    children: newChildren
                )
            }
        }

        return self
    }

    static func ==(lhs: GMImmutableContainerNode<Element>, rhs: GMImmutableContainerNode<Element>) -> Bool {
        lhs.element == rhs.element
    }

    private func clone(
        children: [Self]? = nil,
        element: Element? = nil
    ) -> GMImmutableContainerNode {
        GMImmutableContainerNode(
            children: children ?? self.children,
            element: element ?? self.element
        )
    }
}
