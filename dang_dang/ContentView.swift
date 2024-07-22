//
//  ContentView.swift
//  dang_dang
//
//  Created by user on 2024/05/20.
//

import SwiftUI
import WebKit

struct ContentView: View {
    @State private var showLoading: Bool = false
    @State private var canGoBack: Bool = false
    @State private var canGoForward: Bool = false

    var body: some View {
        ZStack {
            WebView(url: URL(string: "http://dang-dang.kr/")!,
                    showLoading: $showLoading,
                    canGoBack: $canGoBack,
                    canGoForward: $canGoForward)
                .edgesIgnoringSafeArea([.leading, .trailing, .bottom])
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if showLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(6)
                    .padding(10)
                    .frame(width: 100, height: 100)
                    .navigationTitle("단일대오")
            }
        }
    }
}

#Preview {
    ContentView()
}
