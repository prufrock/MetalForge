//
// Created by David Kanenwisher on 8/4/21.
//

import Foundation

extension Array {
    func replace(index i: Int, with: Element) -> [Element] {
        Array(self[0 ..< i]) + [with] + Array(self[(i+1) ..< count])
    }
}