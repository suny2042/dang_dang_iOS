//
//  WebView.swift
//  dang_dang
//
//  Created by user on 2024/05/20.
//
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var showLoading: Bool
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        
        // PanGestureRecognizer를 추가합니다.
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePanGesture(_:)))
        webView.addGestureRecognizer(panGesture)
        
        let request = URLRequest(url: url)
        webView.load(request)
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // 업데이트 시 필요한 코드가 있으면 여기에 추가
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(showLoading: $showLoading, canGoBack: $canGoBack, canGoForward: $canGoForward)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        @Binding var showLoading: Bool
        @Binding var canGoBack: Bool
        @Binding var canGoForward: Bool
        
        init(showLoading: Binding<Bool>, canGoBack: Binding<Bool>, canGoForward: Binding<Bool>) {
            _showLoading = showLoading
            _canGoBack = canGoBack
            _canGoForward = canGoForward
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            showLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            showLoading = false
            canGoBack = webView.canGoBack
            canGoForward = webView.canGoForward
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            showLoading = false
        }
        
        @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
            guard let webView = gesture.view as? WKWebView else { return }
            let location = gesture.location(in: gesture.view)
            
            if gesture.state == .began {
                if location.x < 50 { // 화면의 왼쪽 가장자리에서 시작
                    // 뒤로 가기
                    if webView.canGoBack {
                        webView.goBack()
                    }
                } else if location.x > (gesture.view?.frame.width ?? 0) - 50 { // 화면의 오른쪽 가장자리에서 시작
                    // 앞으로 가기
                    if webView.canGoForward {
                        webView.goForward()
                    }
                }
            }
        }
    }
}
