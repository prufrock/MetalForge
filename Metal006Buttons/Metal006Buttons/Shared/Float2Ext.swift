//
// Created by David Kanenwisher on 11/26/21.
//

extension float2 where Scalar == Float  {
    func displayToNdc(display: float2) -> float2 {
        let x = ((x / display.x) * 2) - 1
        let y = 1 - ((y / display.y) * 2)
        return float2(x, y)
    }

    func displayToNdc(display: float2) -> float4x4 {
        let x = ((x / display.x) * 2) - 1
        let y = 1 - ((y / display.y) * 2)
        return float4x4(
            [x, 0.0, 0.0, 0.0],
            [0.0, y, 0.0, 0.0],
            [0.0, 0.0, 1.0, 0.0],
            [0.0, 0.0, 0.0, 1.0]
        )
    }
}