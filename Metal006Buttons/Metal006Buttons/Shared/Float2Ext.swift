//
// Created by David Kanenwisher on 11/26/21.
//

extension Float2 where Scalar == Float  {
    func displayToNdc(display: Float2) -> Float2 {
        let x = ((x / display.x) * 2) - 1
        let y = 1 - ((y / display.y) * 2)
        return Float2(x, y)
    }

    func displayToNdc(display: Float2) -> Float4x4 {
        let x = ((x / display.x) * 2) - 1
        let y = 1 - ((y / display.y) * 2)
        return Float4x4(
            [x, 0.0, 0.0, 0.0],
            [0.0, y, 0.0, 0.0],
            [0.0, 0.0, 1.0, 0.0],
            [0.0, 0.0, 0.0, 1.0]
        )
    }
}