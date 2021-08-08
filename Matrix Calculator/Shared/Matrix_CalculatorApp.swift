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
        application = ViewModel.application(id: UUID(uuidString: "4e6ecfae-9e8d-4464-ba48-976e7f8ed413")!) {
            return $0.undoButton(
                Button(id: UUID(uuidString: "a14fbeec-3c91-4e30-8d25-91b237de41a4")!, disabled: true)
            )
        }.create()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(app: application)
        }
    }
}
