//
//  KORAEntryPoint.swift
//  KORA
//
//  Hosts the core KORA UI inside the Lucent shell,
//  without changing ChatView’s internal logic.
//

import SwiftUI

struct KORAEntryPoint: View {
    var body: some View {
        KORAWorkspace {
            ChatView()
                // Important: let the outer shell control the background
                .background(Color.clear)
        }
    }
}

#Preview {
    KORAEntryPoint()
}
