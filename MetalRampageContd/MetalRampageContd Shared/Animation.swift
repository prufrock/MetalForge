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
    var texture: Texture {
        guard duration > 0 else {
            return frames[0]
        }
        let t = time.truncatingRemainder(dividingBy: duration) / duration
        return frames[Int(Float(frames.count) * t)]
    }
}