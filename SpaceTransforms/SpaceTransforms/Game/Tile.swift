//
//  Tile.swift
//  SpaceTransforms
//
//  Created by David Kanenwisher on 11/22/22.
//

enum Tile: Int, Decodable, CaseIterable {
    // Floors
    case floor = 0

    // Walls
    case wall = 1

    var isWall: Bool {
        switch self {
        case .wall:
            return true
        case .floor:
            return false
        }
    }
}
