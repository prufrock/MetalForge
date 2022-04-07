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

    var textures: [Texture] {
        switch self {
        case .floor:
            return [.floor, .ceiling]
        case .crackFloor:
            return [.crackFloor, .ceiling]
        case .wall:
            return [.wall, .slimeWall]
        case .crackWall:
            return [.crackWall, .crackWall2]
        case .slimeWall:
            return [.slimeWall, .slimeWall2]
        case .doorJamb1:
            return [.doorJamb1]
        case .doorJamb2:
            return [.doorJamb2]
        case .ceiling:
            return [.ceiling]
        }
    }
}
