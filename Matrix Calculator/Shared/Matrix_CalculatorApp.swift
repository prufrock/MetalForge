//
//  Matrix_CalculatorApp.swift
//  Shared
//
//  Created by David Kanenwisher on 7/27/21.
//

import SwiftUI
import ViewModel
import MCLCModel

@main
struct Matrix_CalculatorApp: App {
    var application: VMDLApplication

    init() {
        application = ViewModel.vmdlApplication(id: UUID(uuidString: "734f9abe-f805-4ba9-93f8-c5025ab546b8")!) {
            $0.firstWindow(id: UUID(uuidString: "4e6ecfae-9e8d-4464-ba48-976e7f8ed413")!) {
                $0.undoButton(
                    VMDLButton(id: UUID(uuidString: "a14fbeec-3c91-4e30-8d25-91b237de41a4")!, disabled: true)

                ).redoButton(
                    VMDLButton(id: UUID(uuidString: "32ee82a5-0b75-4689-847d-f49d0cef4a18")!, disabled: true)
                ).dotProductButton(
                    VMDLButton(id: UUID(uuidString: "a14fbeec-3c91-4e30-8d25-91b237de41a4")!, disabled: false)
                ).model(
                    mclcModel(vector: [[5.0, 6.0, 7.0, 8.0]])
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
