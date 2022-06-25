//
//  Rng.swift
//  MetalRampageContd
//
//  Created by David Kanenwisher on 5/12/22.
//

// values to generate random UInt64 numbers
private let multiplier: UInt64 = 6364136223846793005
private let increment: UInt64 = 1442695040888963407

struct GMRng: RandomNumberGenerator {
    private var seed: UInt64 = 0

    init(seed: UInt64) {
        self.seed = seed
    }

    mutating func next() -> UInt64 {
        // Linear Congruential Generator
        // this part ensures values can be generated that use up all the bits of the UInt64
        // the special &* and &+ operators wrap when the value overflows rather than crashing
        // there is no module on the end because overflowing essentially does the modules
        // when it overflows it goes back to 0
        seed = seed &* multiplier &+ increment
        return seed
    }
}

extension Collection where Index == Int {
    // Override random element so that selecting the element randomly
    // works the same across different versions of swift
    func randomElement(using generator: inout GMRng) -> Element? {
        if isEmpty {
            return nil
        }
        return self[startIndex + Index(generator.next() % UInt64(count))]
    }
}