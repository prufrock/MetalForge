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
    var application: VMDLWindow

    init() {
        application = ViewModel.application(id: UUID(uuidString: "4e6ecfae-9e8d-4464-ba48-976e7f8ed413")!) {
            return $0.undoButton(
                VMDLButton(id: UUID(uuidString: "a14fbeec-3c91-4e30-8d25-91b237de41a4")!, disabled: true)
            ).dotProductButton(
                VMDLButton(id: UUID(uuidString: "a14fbeec-3c91-4e30-8d25-91b237de41a4")!, disabled: false)
            )
        }.create()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(app: application)
        }
    }
}
