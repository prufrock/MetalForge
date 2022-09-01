//
// Created by David Kanenwisher on 12/26/21.
//

import Foundation

enum GMThing: Int, Decodable {
    case nothing          // 0
    case player           // 1
    case monster          // 2
    case door             // 3
    case pushWall         // 4
    case `switch`         // 5
    case healingPotion    // 6
    case fireBlast        // 7
    case monsterBlob      // 8 but really it's a variant of monster
}
