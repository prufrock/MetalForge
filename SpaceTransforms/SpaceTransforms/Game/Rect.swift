//
//  Rect.swift
//  SpaceTransforms
//
//  Created by David Kanenwisher on 11/23/22.
//

struct Rect {
    var min, max: Float2

    func intersection(with rect: Rect) -> Float2? {
        let left = Float2(x: max.x - rect.min.x, y: 0) // world
        if left.x <= 0 {
            return nil
        }
        let right = Float2(x: min.x - rect.max.x, y: 0) // world
        if right.x >= 0 {
            return nil
        }
        let up = Float2(x: 0, y: max.y - rect.min.y) // world
        if up.y <= 0 {
            return nil
        }
        let down = Float2(x: 0, y: min.y - rect.max.y) // world
        if down.y >= 0 {
            return nil
        }

        // sort by length with the smallest first and grab that one
        return [left, right, up, down].sorted(by: { $0.length < $1.length }).first
    }
}
