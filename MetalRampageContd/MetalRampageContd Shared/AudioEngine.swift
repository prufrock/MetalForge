//
// Created by David Kanenwisher on 4/12/22.
//

class AudioEngine {
    func setUpAudio() {
        for name in SoundName.allCases {
            precondition(name.url != nil, "Missing mp3 file for \(name.rawValue)")
        }
        try? SoundManager.shared.activate()
    }

    func play(_ sounds: [Sound]) {
        for sound in sounds {
            guard let url = sound.name.url else {
                continue
            }
            try? SoundManager.shared.play(url)
        }
    }
}

extension SoundName {
    var url: URL? {
        Bundle.main.url(forResource: rawValue, withExtension: "mp3")
    }
}
