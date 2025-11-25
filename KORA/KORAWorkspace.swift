//
//  KORAWorkspace.swift
//  KORA
//
//  Lucent-style shell that wraps the existing KORA UI
//  without touching the pulsating orb, chat bubbles,
//  or SmartIntent logic.
//

import SwiftUI

// MARK: - Top-Level Shell
// Use this as your new app root wrapper around the existing KORA content.
// Example in ContentView:
//   var body: some View {
//       KORAUnifiedShell {
//           ChatView() // your current KORA chat root
//       }
//   }

struct KORAUnifiedShell<Content: View>: View {
    private let title: String
    private let content: () -> Content
    
    init(
        title: String = "KORA",
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        NavigationStack {
            KORAWorkspace {
                content()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    KORALogoOrb()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    KORAStatusPill()
                }
            }
        }
    }
}

// MARK: - Workspace Layout
// This is the Lucent-style layout frame that wraps your existing KORA view.
// It does NOT change your internal background or message styling.

struct KORAWorkspace<Content: View>: View {
    private let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            
            ZStack {
                // Deep backdrop
                LinearGradient(
                    colors: [
                        Color.black,
                        Color.black.opacity(0.95)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer(minLength: 8)
                    
                    ZStack {
                        // Lucent-style panel behind KORA
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                            )
                            .shadow(
                                color: Color.black.opacity(0.55),
                                radius: 32,
                                x: 0,
                                y: 20
                            )
                        
                        // Your existing KORA chat UI
                        content()
                            .clipShape(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                            )
                            .padding(10)
                    }
                    .frame(
                        maxWidth: min(size.width * 0.94, 720),
                        maxHeight: size.height * 0.90,
                        alignment: .center
                    )
                    .padding(.horizontal, 12)
                    .padding(.bottom, 24)
                }
                .frame(width: size.width, height: size.height)
            }
        }
    }
}

// MARK: - Lucent-Style Card Container
// Use this for panels, secondary modules, tools, etc. inside KORA.

struct KORACardContainer<Content: View>: View {
    let title: String?
    let subtitle: String?
    let content: () -> Content
    
    init(
        title: String? = nil,
        subtitle: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if title != nil || subtitle != nil {
                VStack(alignment: .leading, spacing: 4) {
                    if let title {
                        Text(title)
                            .font(.system(.headline, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.96))
                    }
                    if let subtitle {
                        Text(subtitle)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.55))
                    }
                }
                .padding(.horizontal, 4)
            }
            
            content()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.systemBackground).opacity(0.18))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                )
        )
        .shadow(
            color: Color.black.opacity(0.40),
            radius: 18,
            x: 0,
            y: 12
        )
    }
}

// MARK: - Small UI Elements (Lucent x KORA)

// Minimal KORA orb in the nav bar.
// If you already have an orb icon asset, swap it in here.

struct KORALogoOrb: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.orange.opacity(0.9),
                            Color.red.opacity(0.7),
                            Color.black.opacity(0.8)
                        ],
                        center: .center,
                        startRadius: 2,
                        endRadius: 22
                    )
                )
                .frame(width: 28, height: 28)
                .shadow(
                    color: Color.orange.opacity(0.6),
                    radius: 10,
                    x: 0,
                    y: 4
                )
            
            Circle()
                .strokeBorder(Color.white.opacity(0.28), lineWidth: 0.8)
                .frame(width: 28, height: 28)
        }
        .accessibilityLabel("KORA")
    }
}

// Compact status pill on the trailing side of the nav bar.
// You can wire this up to real system state later.

struct KORAStatusPill: View {
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color.green.opacity(0.85))
                .frame(width: 7, height: 7)
            
            Text("Online")
                .font(.system(size: 13, weight: .medium, design: .rounded))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule(style: .continuous)
                .fill(Color.white.opacity(0.10))
        )
        .overlay(
            Capsule(style: .continuous)
                .strokeBorder(Color.white.opacity(0.18), lineWidth: 0.8)
        )
        .shadow(
            color: Color.black.opacity(0.35),
            radius: 10,
            x: 0,
            y: 5
        )
    }
}

// MARK: - Helpful Modifiers & Extensions

struct KORACardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color(.systemBackground).opacity(0.16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                    )
            )
            .shadow(
                color: Color.black.opacity(0.35),
                radius: 16,
                x: 0,
                y: 10
            )
    }
}

extension View {
    /// Apply Lucent-style card appearance to any block.
    func koraCardStyle() -> some View {
        modifier(KORACardModifier())
    }
}
