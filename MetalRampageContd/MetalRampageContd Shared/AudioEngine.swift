//
// Created by David Kanenwisher on 4/12/22.
//

class AudioEngine {
    func setUpAudio() {
        for name in SoundName.allCases {
            precondition(name.url != nil, "Missing mp3 file for \(name.rawValue)")
        }
        try? SoundManager.shared.activate()

        // Boot up the sound manager by loading a file
        _ = try? SoundManager.shared.preload(SoundName.allCases[0].url!)
    }

    func play(_ sounds: [Sound]) {
        for sound in sounds {
            // delay before playing the sound to mimic the speed of sound
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(sound.delay)) {
                guard let url = sound.name.url else {
                    return
                }
                try? SoundManager.shared.play(url, volume: sound.volume)
            }
        }
    }
}

extension SoundName {
    var url: URL? {
        Bundle.main.url(forResource: rawValue, withExtension: "mp3")
    }
}
