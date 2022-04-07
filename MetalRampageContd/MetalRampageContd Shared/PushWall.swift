//
// Created by David Kanenwisher on 4/6/22.
//

struct PushWall {
    var position: Float2
    let tile: Tile

    init(position: Float2, tile: Tile) {
        self.position = position
        self.tile = tile
    }
}

extension PushWall {
    // The collision rectangle
    var rect: Rect {
        Rect(
            min: position - Float2(x: 0.5, y: 0.5),
            max: position + Float2(x: 0.5, y: 0.5)
        )
    }

    // The billboards are used for hitTest what things can see and for rendering
    var billboards: [Billboard] {
        let topLeft = rect.min, bottomRight = rect.max
        let topRight = Float2(x: bottomRight.x, y: topLeft.y)
        let bottomLeft = Float2(x: topLeft.x, y: bottomRight.y)
        let textures = tile.textures
        // The push wall has 4 walls so it had 4 billboards placed into position
        return [
            Billboard(start: topLeft, direction: Float2(x: 0, y: 1), length: 1, position: Float2(position.x + 0.5, position.y), texture: textures[0]),
            Billboard(start: topRight, direction: Float2(x: -1, y: 0), length: 1, position: Float2(position.x, position.y - 0.5), texture: textures[1]),
            Billboard(start: bottomRight, direction: Float2(x: 0, y: -1), length: 1, position: Float2(position.x - 0.5, position.y), texture: textures[0]),
            Billboard(start: bottomLeft, direction: Float2(x: 1, y: 0), length: 1, position: Float2(position.x, position.y + 0.5), texture: textures[1]),
        ]
    }
}