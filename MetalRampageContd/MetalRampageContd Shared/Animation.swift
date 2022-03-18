//
// Created by David Kanenwisher on 3/18/22.
//
struct Animation {
    let frames: [Texture]
    let duration: Float
    var time: Float = 0

    init(frames: [Texture], duration: Float) {
        self.frames = frames
        self.duration = duration
    }
}

extension Animation {
    static let monsterIdle = Animation(frames: [.monster], duration: 0)
    static let monsterWalk = Animation(frames: [.monsterWalk1, .monsterWalk2], duration: 0.5)

    var texture: Texture {
        guard duration > 0 else {
            return frames[0]
        }
        let t = time.truncatingRemainder(dividingBy: duration) / duration
        return frames[Int(Float(frames.count) * t)]
    }
}