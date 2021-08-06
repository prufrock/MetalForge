//
//  Matrix_CalculatorApp.swift
//  Shared
//
//  Created by David Kanenwisher on 7/27/21.
//

import SwiftUI
import ViewModel

@main
struct Matrix_CalculatorApp: App {
    var application: Application

    init() {
        application = Application(id: UUID(uuidString: "4e6ecfae-9e8d-4464-ba48-976e7f8ed413")!) {
            Button(id: UUID(uuidString: "6101a91c-1ebe-47ca-9744-d342e51e96d1")!, disabled: true)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(app: application)
        }
    }
}
