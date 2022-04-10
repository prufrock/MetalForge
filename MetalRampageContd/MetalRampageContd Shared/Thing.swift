//
// Created by David Kanenwisher on 12/26/21.
//

import Foundation

public enum Thing: Int, Decodable {
    case nothing
    case player
    case monster
    case door
    case pushWall
    case `switch`
}
