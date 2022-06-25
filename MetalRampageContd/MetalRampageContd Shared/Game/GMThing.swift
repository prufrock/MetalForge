//
// Created by David Kanenwisher on 12/26/21.
//

import Foundation

public enum GMThing: Int, Decodable {
    case nothing          // 0
    case player           // 1
    case monster          // 2
    case door             // 3
    case pushWall         // 4
    case `switch`         // 5
    case healingPotion    // 6
    case fireBlast        // 7
}
