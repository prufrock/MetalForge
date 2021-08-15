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
    var application: VMDLApplication

    init() {
        application = ViewModel.vmdlApplication(id: UUID(uuidString: "734f9abe-f805-4ba9-93f8-c5025ab546b8")!) {
            $0.firstWindow(id: UUID(uuidString: "4e6ecfae-9e8d-4464-ba48-976e7f8ed413")!) {
                $0.undoButton(
                    VMDLButton(id: UUID(uuidString: "a14fbeec-3c91-4e30-8d25-91b237de41a4")!, disabled: true)
                ).dotProductButton(
                    VMDLButton(id: UUID(uuidString: "a14fbeec-3c91-4e30-8d25-91b237de41a4")!, disabled: false)
                )
            }
        }.create()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(window: application.firstWindow)
        }
    }
}
