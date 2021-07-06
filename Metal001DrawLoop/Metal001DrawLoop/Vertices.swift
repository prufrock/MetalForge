//
// Created by David Kanenwisher on 7/6/21.
//

// I'm going to start by making this a struct and see how far I get.
// So far this seems like a pretty thin wrapper. I'm hoping it provides an decent abstraction to hang
// some helpful functions on. It might be premature to create this class. Sometimes it's nice to have
// a place where I can ideas on.
struct Vertices {
    let vertices: [Point]

    init(_ vertices: [Point]) {
        self.vertices = vertices
    }

    init(_ vertices: Point...) {
        self.vertices = vertices
    }
}
