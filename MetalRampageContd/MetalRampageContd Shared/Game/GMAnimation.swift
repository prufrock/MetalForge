//
// Created by David Kanenwisher on 3/18/22.
//
struct GMAnimation {
    let frames: [GMTexture]
    let duration: Float
    var time: Float = 0

    init(frames: [GMTexture], duration: Float) {
        self.frames = frames
        self.duration = duration
    }
}

extension GMAnimation {
    var texture: GMTexture {
        guard duration > 0 else {
            return frames[0]
        }
        let t = time.truncatingRemainder(dividingBy: duration) / duration
        return frames[Int(Float(frames.count) * t)]
    }

    // makes it possible to know when an animation has finished and perform some action in response
    var isCompleted: Bool {
        time >= duration
    }
}