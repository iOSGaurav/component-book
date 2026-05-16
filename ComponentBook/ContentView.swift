//
//  ContentView.swift
//  ComponentBook
//
//  Created by Gaurav Parmar on 16/05/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Components") {
                    NavigationLink {
                        ButtonGallery()
                    } label: {
                        Label("Button", systemImage: "rectangle.and.hand.point.up.left.fill")
                    }
                }
            }
            .navigationTitle("ComponentBook")
        }
    }
}

#Preview {
    ContentView()
}
