//
//  Colors.swift
//  Metal003GameLoop
//
//  Created by David Kanenwisher on 9/19/21.
//

struct Colors {
    let black = float4(0.0, 0.0, 0.0, 1.0)
    let red = float4(1.0, 0.0, 0.0, 1.0)
    let green = float4(0.0, 1.0, 0.0, 1.0)
    let blue = float4(0.0, 0.0, 1.0, 1.0)
    let white = float4(1.0, 1.0, 1.0, 1.0)
}

enum ColorsE: Int {
    case black = 0x000000
    case red = 0xFF0000
    case green = 0x00FF00
    case blue = 0x0000FF
    case white = 0xFFFFFF

    // shift to the right x places
    // then only take FF(the two right most hex digits or 8 most bits)
    func r() -> Int {
       rawValue >> 16 & 0xFF
    }

    func g() -> Int {
        rawValue >> 8 & 0xFF
    }

    func b() -> Int {
        rawValue >> 0 & 0xFF
    }
}
