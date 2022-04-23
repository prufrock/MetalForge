//
//  StringExt.swift
//  MetalRampageContd
//
//  Created by David Kanenwisher on 4/22/22.
//

extension String {
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let stringLength = self.count
        if stringLength < toLength {
            return String(repeatElement(character, count: toLength - stringLength)) + self
        } else {
            return String(self.suffix(toLength))
        }
    }

    /**
     Returns the character.
     - Parameter location: The location of the character to return.
     - Returns: The character found at the location if there is one.
     */
    func char(at location: Int) -> Character? {
        let startIndex = index(startIndex, offsetBy: location)
        let upToChar = self[...startIndex]
        return upToChar.last
    }

    func charInt(at location: Int) -> Int? {
        guard let c = char(at: location) else {
            return nil
        }

        return Int(String(c))
    }
}
