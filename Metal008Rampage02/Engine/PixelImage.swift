//
// Created by David Kanenwisher on 12/15/21.
//

struct PixelImage {
    var vertices: [([Float4], Color)]
    let pixelSize:Float

    init(bitmap: Bitmap, pixelSize: Float = 81.0) {
        self.pixelSize = pixelSize

        var myVertices: [([Float4], Color)] = []
        for y in 0 ..< bitmap.height {
            for x in 0 ..< bitmap.width {
                myVertices.append(([Float4(Float(x), Float(-y), 0.0, 1.0)], bitmap[x,y]))
            }
        }

        vertices = myVertices
    }
}
