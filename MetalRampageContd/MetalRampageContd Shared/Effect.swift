//
// Created by David Kanenwisher on 3/21/22.
//

enum EffectType {
    case fadeIn
}

class Effect {
    let type: EffectType
    let color: Color
    let duration: Float
    var time: Float = 0

    init(type: EffectType, color: Color, duration: Float) {
        self.type = type
        self.color = color
        self.duration = duration
    }

    func asFloat4() -> Float4 {
        Float4(color, alpha: Float(1 - progress))
    }
}

extension Effect {
    var isCompleted: Bool {
        time >= duration
    }

    var progress: Float {
        min(1, time / duration)
    }
}
