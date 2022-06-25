//
//  GMPathfinder.swift
//  MetalRampageContd
//
//  Created by David Kanenwisher on 4/17/22.
//

protocol GMGraph {
    /**
     A Node is a vertex on a path.
     */
    associatedtype Node: Hashable

    /**
     Determines which Nodes can reached from the given Node.
     - Parameter node: The Node to start from.
     - Returns: The connected Nodes.
     */
    func nodesConnectedTo(_ node: Node) -> [Node]
    /**
     Make an educated guess at the distance between two Nodes.
     - Parameters:
       - a: the start Node
       - b: the end Node
     - Returns: The distance between the Nodes
     */
    func estimatedDistance(from a: Node, to b: Node) -> Float
    /**
     The exact distance between two Nodes.
     - Parameters:
       - a: the start Node
       - b: the end Node
     - Returns: The distance between the Nodes
     */
    func stepDistance(from a: Node, to b: Node) -> Float
}

/**
 A path to somewhere.
 */
private class GMPath<Node> {
    let head: Node
    let tail: GMPath?
    // the total steps taken to from the start to the head
    let distanceTraveled: Float
    // the total steps travel and the estimated distanced remaining
    let totalDistance: Float

    init(head: Node, tail: GMPath?, stepDistance: Float, remaining: Float) {
        self.head = head
        self.tail = tail
        self.distanceTraveled = (tail?.distanceTraveled ?? 0) + stepDistance
        self.totalDistance = distanceTraveled + remaining
    }

    // Gather up the nodes into an array
    var nodes: [Node] {
        var nodes = [head]
        var tail = self.tail
        while let path = tail {
            nodes.insert(path.head, at: 0)
            tail = path.tail
        }
        // don't include the starting point
        nodes.removeFirst()
        return nodes
    }
}

extension GMGraph {
    func findPath(from start: Node, to end: Node, maxDistance: Float) -> [Node] {
        var visited = Set([start])
        var paths = [GMPath(
            head: start,
            tail: nil,
            stepDistance: 0,
            remaining: estimatedDistance(from: start, to: end)
        )]
        while let path = paths.popLast() {
            // Yay, we found a path!
            if path.head == end {
                return path.nodes
            }

            // look through all the nodes connected to head, skipping visited ones
            for node in nodesConnectedTo(path.head) where !visited.contains(node) {
                // don't explore the visited nodes
                visited.insert(node)
                let next = GMPath(
                    head: node,
                    tail: path,
                    stepDistance: stepDistance(from: path.head, to: node),
                    remaining: estimatedDistance(from: node, to: end)
                )
                // go on to the next if the distance is greater than the max distance
                if next.totalDistance > maxDistance {
                    break
                }
                // put the shortest path last
                // keeping the list organized by distance
                if let index = paths.firstIndex(where: {
                    $0.totalDistance <= next.totalDistance
                }) {
                    paths.insert(next, at: index)
                } else {
                    paths.append(next)
                }
            }
        }

        // if we couldn't find a path return an empty array
        return []
    }
}