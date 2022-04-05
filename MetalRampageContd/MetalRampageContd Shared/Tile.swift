//
// Created by David Kanenwisher on 12/26/21.
//

public enum Tile: Int, Decodable, CaseIterable {
    // Ceiling
    case ceiling = 5

    // Floors
    case floor = 0
    case crackFloor = 4

    // Walls
    case wall = 1
    case crackWall = 2
    case slimeWall = 3

    // Doorjambs
    case doorJamb1 = 6
    case doorJamb2 = 7
}

public extension Tile {
    var isWall: Bool {
        switch self {
        case .wall, .crackWall, .slimeWall, .doorJamb1, .doorJamb2:
            return true
        case .floor, .crackFloor, .ceiling:
            return false
        }
    }
}
