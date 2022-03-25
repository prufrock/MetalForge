//
// Created by David Kanenwisher on 3/21/22.
//

enum EffectType {
    case fadeIn
    case fadeOut
}

class Effect {
    let type: EffectType
    let color: ColorA
    let duration: Float
    var time: Float = 0

    init(type: EffectType, color: ColorA, duration: Float) {
        self.type = type
        self.color = color
        self.duration = duration
    }

    func asFloat4() -> Float4 {
        Float4(color.r, color.g, color.b, progress)
    }
}

extension Effect {
    var isCompleted: Bool {
        time >= duration
    }

    var progress: Float {
        let t = min(1, time / duration)
        switch type {
        case .fadeIn:
            return color.a - Easing.easeIn(t)
        case .fadeOut:
            return Easing.easeOut(t)
        }
    }
}
