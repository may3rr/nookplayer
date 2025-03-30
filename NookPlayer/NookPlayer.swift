import SwiftUI
import AppKit
import AVFoundation

@main
struct NookPlayerMacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // 主视图
                ContentView()
                
                // 这个视图的唯一目的是访问NSWindow对象
                Color.clear
                    .frame(width: 0, height: 0)
                    .background(WindowAccessor())
            }
            .frame(width: 298, height: 91)
        }
    }
}

// 这个结构体用于访问和修改窗口属性
struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                // 完全禁用窗口调整大小功能
                window.styleMask.remove(.resizable)
                window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                window.standardWindowButton(.zoomButton)?.isHidden = true
                window.standardWindowButton(.closeButton)?.isHidden = false
                
                // 设置窗口大小
                window.setContentSize(NSSize(width: 298, height: 91))
                window.minSize = NSSize(width: 298, height: 91)
                window.maxSize = NSSize(width: 298, height: 91)
                
                // 窗口标题栏设置
                window.titlebarAppearsTransparent = true
                window.titleVisibility = .hidden
                window.isMovableByWindowBackground = true
                
                print("窗口设置已应用: 大小固定为 298x91")
            }
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 确保应用程序在Dock中可见
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        
        // 复制图标到应用程序图标位置
        setupAppIcon()
    }
    
    private func setupAppIcon() {
        // 查找图标文件
        let projectPath = "/Users/jackielyu/Downloads/代码项目/nookplayer"
        let iconPath = "\(projectPath)/bar.png"
        
        if FileManager.default.fileExists(atPath: iconPath) {
            // 设置应用图标
            if let image = NSImage(contentsOfFile: iconPath) {
                NSApp.applicationIconImage = image
                print("应用图标已设置")
            }
        }
    }
}
