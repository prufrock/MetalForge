//
// Created by David Kanenwisher on 3/18/22.
//
struct Animation {
    let frames: [Texture]
    let duration: Float

    init(frames: [Texture], duration: Float) {
        self.frames = frames
        self.duration = duration
    }
}

extension Animation {
    static let monsterIdle = Animation(frames: [.monster], duration: 0)
    static let monsterWalk = Animation(frames: [.monsterWalk1, .monsterWalk2], duration: 0.5)
}