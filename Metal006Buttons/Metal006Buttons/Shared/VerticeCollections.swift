//
//  VerticeCollections.swift
//  Metal003GameLoop
//
//  Created by David Kanenwisher on 9/19/21.
//

struct VerticeCollection {
    let c: [name: Vertices]

    enum name {
        case singlePoint
        case originPoint
        case cube
        case square
    }

    init() {
        c = [
            .singlePoint: Vertices(Point(0.5, 0.2, 0.0)),
            .originPoint: Vertices(Point(0.0, 0.0, 0.0)),
            .cube: Vertices(
            // First Square
            Point(0.2, 0.2, 0.0),
            Point(-0.2, 0.2, 0.0),
            Point(-0.2, 0.2, 0.0),
            Point(-0.2, -0.2, 0.0),
            Point(-0.2, -0.2, 0.0),
            Point(0.2, -0.2, 0.0),
            Point(0.2, -0.2, 0.0),
            // Second Square
            Point(0.2, 0.2, 0.0),
            Point(0.2, 0.2, 0.2),
            Point(-0.2, 0.2, 0.2),
            Point(-0.2, 0.2, 0.2),
            Point(-0.2, -0.2, 0.2),
            Point(-0.2, -0.2, 0.2),
            Point(0.2, -0.2, 0.2),
            Point(0.2, -0.2, 0.2),
            Point(0.2, 0.2, 0.2),
            // Connecting lines
            Point(0.2, 0.2, 0.0),
            Point(0.2, 0.2, 0.2),
            Point(-0.2, 0.2, 0.0),
            Point(-0.2, 0.2, 0.2),
            Point(-0.2, -0.2, 0.0),
            Point(-0.2, -0.2, 0.2),
            Point(0.2, -0.2, 0.0),
            Point(0.2, -0.2, 0.2),
            primitiveType: .line),
            .square: Vertices (
            Point(0.2, 0.2, 0.0),
            Point(-0.2, 0.2, 0.0),
            Point(-0.2, 0.2, 0.0),
            Point(-0.2, -0.2, 0.0),
            Point(-0.2, -0.2, 0.0),
            Point(0.2, -0.2, 0.0),
            Point(0.2, -0.2, 0.0),
            Point(0.2, 0.2, 0.0),
            primitiveType: .line
            ),
        ]
    }
}
