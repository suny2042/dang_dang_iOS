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
        webView.uiDelegate = context.coordinator // uiDelegate 설정
        
        // PanGestureRecognizer를 추가합니다.
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePanGesture(_:)))
        webView.addGestureRecognizer(panGesture)
        
        // 쿠키를 관리하여 세션 지속성을 보장
        let dataStore = WKWebsiteDataStore.default()
        webView.configuration.websiteDataStore = dataStore
        
        // 자바스크립트를 활성화
        //webView.configuration.preferences.javaScriptEnabled = true

        
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
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        @Binding var showLoading: Bool
        @Binding var canGoBack: Bool
        @Binding var canGoForward: Bool
        var completionHandler: (([URL]?) -> Void)?
        
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
        
        
        // 2024.07.29 윤기선 alert, confirm, prompt 핸들링
       func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
           let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
               completionHandler()
           }))
           UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
       }
       
       func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
           let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
               completionHandler(false)
           }))
           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
               completionHandler(true)
           }))
           UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
       }
       
       func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
           let alert = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
           alert.addTextField { textField in
               textField.text = defaultText
           }
           alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
               completionHandler(nil)
           }))
           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
               completionHandler(alert.textFields?.first?.text)
           }))
           UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
       }
        
        // 웹사이트에서 알림 권한을 요청할 때 이를 처리할 수 있도록 설정
        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            if let httpResponse = navigationResponse.response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    decisionHandler(.allow)
                } else {
                    decisionHandler(.cancel)
                }
            } else {
                decisionHandler(.cancel)
            }
        }

        // 파일 업로드를 위한 파일 선택 핸들러
                func webView(_ webView: WKWebView, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping ([URL]?) -> Void) {
                    self.completionHandler = completionHandler
                    
                    let alert = UIAlertController(title: "Upload Image", message: "Choose a source", preferredStyle: .actionSheet)
                    
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                            self.presentImagePicker(sourceType: .camera)
                        }))
                    }
                    
                    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
                            self.presentImagePicker(sourceType: .photoLibrary)
                        }))
                    }
                    
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                        completionHandler(nil)
                    }))
                    
                    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                }
                
                // 이미지 피커 표시
                func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
                    let imagePickerController = UIImagePickerController()
                    imagePickerController.delegate = self
                    imagePickerController.sourceType = sourceType
                    UIApplication.shared.windows.first?.rootViewController?.present(imagePickerController, animated: true, completion: nil)
                }
                
                // 이미지 선택 완료 후 처리
                func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                    if let imageURL = info[.imageURL] as? URL {
                        completionHandler?([imageURL])
                    } else if let image = info[.originalImage] as? UIImage {
                        // 이미지 저장 후 URL 반환
                        let tempDirectory = FileManager.default.temporaryDirectory
                        let imageName = UUID().uuidString + ".jpg"
                        let imageURL = tempDirectory.appendingPathComponent(imageName)
                        if let jpegData = image.jpegData(compressionQuality: 1.0) {
                            try? jpegData.write(to: imageURL)
                            completionHandler?([imageURL])
                        } else {
                            completionHandler?(nil)
                        }
                    }
                    picker.dismiss(animated: true, completion: nil)
                }
                
                func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                    completionHandler?(nil)
                    picker.dismiss(animated: true, completion: nil)
                }
        
    }
}
