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

    // Switches
    case wallSwitch = 8

    // Elevator
    case elevatorFloor = 9
    case elevatorSideWall = 10
    case elevatorBackWall = 11
}

public extension Tile {
    var isWall: Bool {
        switch self {
        case .wall, .crackWall, .slimeWall, .doorJamb1, .doorJamb2, .wallSwitch, .elevatorSideWall, .elevatorBackWall:
            return true
        case .floor, .crackFloor, .ceiling, .elevatorFloor:
            return false
        }
    }

    var textures: [Texture] {
        switch self {
        case .floor, .elevatorFloor:
            return [.floor, .ceiling]
        case .crackFloor:
            return [.crackFloor, .ceiling]
        case .wall, .elevatorBackWall, .elevatorSideWall:
            return [.wall, .slimeWall]
        case .crackWall:
            return [.crackWall, .crackWall]
        case .slimeWall:
            return [.slimeWall, .slimeWall]
        case .doorJamb1:
            return [.doorJamb1]
        case .doorJamb2:
            return [.doorJamb2]
        case .ceiling:
            return [.ceiling]
        case .wallSwitch:
            return [.switch1]
        }
    }

    static let lengthMeters: Float = 2.0
}
