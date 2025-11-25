//
//  ContentView.swift
//  KORA
//
//  Wrapped in the Lucent-style shell (Option B)
//  without altering KORA’s internal UI or logic.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        KORAUnifiedShell {
            KORAEntryPoint()
        }
    }
}

#Preview {
    ContentView()
}
