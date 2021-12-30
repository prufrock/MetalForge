//
// Created by David Kanenwisher on 12/26/21.
//

public enum Tile: Int, Decodable {
    case floor
    case wall
}

public extension Tile {
    var isWall: Bool {
        switch self {
        case .wall:
            return true
        case .floor:
            return false
        }
    }
}
