//
//  Colors.swift
//  Metal003GameLoop
//
//  Created by David Kanenwisher on 9/19/21.
//

enum Colors: Int {
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

    func rFloat() -> Float {
        Float(r()) / 255.0
    }

    func gFloat() -> Float {
        Float(g()) / 255.0
    }

    func bFloat() -> Float {
        Float(b()) / 255.0
    }
}

extension Float4 {
    init(_ color: Colors) {
        self.init(color.rFloat(), color.gFloat(), color.bFloat(), 1.0)
    }
}
