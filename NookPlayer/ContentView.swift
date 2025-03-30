import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var player: AVAudioPlayer?
    @State private var currentWeather: Weather = .sunny
    @State private var isPlaying: Bool = true
    @State private var volume: Float = 0.8
    @State private var isLooping: Bool = true
    @State private var progress: Float = 0.0
    @State private var timer: Timer?
    @State private var currentTimeString: String = ""
    
    private let progressBarImageName = "bar"
    
    enum Weather: String, CaseIterable {
        case sunny = "Sunny"
        case rainy = "Rainy"
        case snowy = "Snowy"
    }
    
    var body: some View {
        ZStack {
            // 使用统一的背景色
            Color(NSColor.windowBackgroundColor)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 8) {
                // Progress bar with custom image
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // 使用固定颜色作为后备
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.blue)
                                .frame(width: CGFloat(progress) * geometry.size.width, height: 4)
                            
                            // 尝试加载图片
                            if let image = NSImage(named: "bar") ?? loadImageFromBundle(named: "bar") {
                                Image(nsImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 4)
                                    // 左右滑动而不是放大
                                    .offset(x: CGFloat(progress) * geometry.size.width - geometry.size.width, y: 0)
                                    .frame(width: geometry.size.width, height: 4, alignment: .leading)
                                    .clipped()
                            }
                        }
                    }
                    .frame(height: 4)
                }
                .padding(.horizontal, 8)
                .padding(.top, 8)
                
                HStack {
                    // Controls
                    HStack(spacing: 16) {
                        // Volume control
                        HStack(spacing: 4) {
                            Image(systemName: "speaker.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            
                            Slider(value: $volume, in: 0...1) { _ in
                                player?.volume = volume
                            }
                            .frame(width: 60)
                            .accentColor(.gray)
                        }
                        
                        // Play/Pause button
                        Button(action: {
                            togglePlayPause()
                        }) {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.gray)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Loop button
                        Button(action: {
                            isLooping.toggle()
                            player?.numberOfLoops = isLooping ? -1 : 0
                        }) {
                            Image(systemName: "repeat")
                                .foregroundColor(isLooping ? .accentColor : .gray)
                                .font(.system(size: 14))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Spacer()
                    
                    // Weather selection
                    // 确保天气按钮有足够的宽度
                    HStack(spacing: 6) {
                        ForEach(Weather.allCases, id: \.self) { weather in
                            Button(action: {
                                changeWeather(to: weather)
                            }) {
                                Text(weather.rawValue)
                                    .font(.system(size: 11, weight: .medium))
                                    .frame(minWidth: 40, maxWidth: .infinity)
                                    .padding(.vertical, 3)
                                    .background(currentWeather == weather ? Color.blue : Color(NSColor.controlBackgroundColor))
                                    .foregroundColor(currentWeather == weather ? .white : Color(NSColor.labelColor))
                                    .cornerRadius(4)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .frame(maxWidth: 140)
                    
                    Spacer()
                    
                    // Current time
                    Text(currentTimeString)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .padding(.trailing, 8)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
        }
        .frame(width: 298, height: 91)
        .onAppear {
            updateCurrentTime()
            setupTimer()
            loadCurrentSong()
        }
    }
    
    private func loadImageFromBundle(named name: String) -> NSImage? {
        // 尝试从Bundle中加载图像
        if let bundlePath = Bundle.main.resourcePath {
            let possiblePaths = [
                "\(bundlePath)/Assets.xcassets/bar.imageset/bar.png",
                "\(bundlePath)/\(name).png",
                "\(bundlePath)/Resources/\(name).png"
            ]
            
            for path in possiblePaths {
                if FileManager.default.fileExists(atPath: path) {
                    return NSImage(contentsOfFile: path)
                }
            }
        }
        
        // 尝试从项目目录加载
        let projectPath = "/Users/jackielyu/Downloads/代码项目/nookplayer"
        let possibleProjectPaths = [
            "\(projectPath)/\(name).png",
            "\(projectPath)/NookPlayer/Assets.xcassets/bar.imageset/\(name).png"
        ]
        
        for path in possibleProjectPaths {
            if FileManager.default.fileExists(atPath: path) {
                return NSImage(contentsOfFile: path)
            }
        }
        
        return nil
    }
    
    private func togglePlayPause() {
        isPlaying.toggle()
        
        if let player = player {
            if isPlaying {
                player.play()
            } else {
                player.pause()
            }
        } else {
            loadCurrentSong()
        }
    }
    
    private func updateCurrentTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        currentTimeString = formatter.string(from: Date())
    }
    
    private func setupTimer() {
        // Update progress bar
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if let player = player, player.duration > 0 {
                progress = Float(player.currentTime / player.duration)
            }
            
            // Update time every minute
            let calendar = Calendar.current
            let components = calendar.dateComponents([.second], from: Date())
            if components.second == 0 {
                updateCurrentTime()
            }
        }
    }
    
    private func loadCurrentSong() {
        updateCurrentTime()
        
        // 使用一个与文件名格式完全匹配的时间格式
        var hour = Calendar.current.component(.hour, from: Date())
        let isPM = hour >= 12
        if hour > 12 { hour -= 12 }
        if hour == 0 { hour = 12 }
        let timeString = "\(hour)：00 \(isPM ? "p.m." : "a.m.")"
        
        let songName = "Nintendo Sound Team - \(timeString) (\(currentWeather.rawValue)).mp3"
        print("Loading song: \(songName)")
        playMusic(fileName: songName)
    }
    
    private func changeWeather(to weather: Weather) {
        if currentWeather != weather {
            currentWeather = weather
            fadeOutAndPlayNewSong()
        }
    }
    
    private func fadeOutAndPlayNewSong() {
        if let currentPlayer = player {
            // Fade out
            let fadeOutTime = 1.0 // 1 second fade out
            let fadeInterval = 0.1
            let volumeDecrement = currentPlayer.volume / Float(fadeOutTime / fadeInterval)
            
            var fadeOutTimer: Timer?
            fadeOutTimer = Timer.scheduledTimer(withTimeInterval: fadeInterval, repeats: true) { timer in
                if let player = self.player, player.volume > volumeDecrement {
                    player.volume -= volumeDecrement
                } else {
                    fadeOutTimer?.invalidate()
                    self.player?.stop()
                    self.loadCurrentSong() // Load new song after fade out
                }
            }
        } else {
            loadCurrentSong()
        }
    }
    
    private func playMusic(fileName: String) {
        // 考虑从bundle中加载音乐文件
        var musicDir = "/Users/jackielyu/Downloads/代码项目/nookplayer/Resources/Musics"
        var documentsPath = "\(musicDir)/\(fileName)"
        
        // 检查从应用程序bundle加载
        if let bundlePath = Bundle.main.resourcePath {
            let bundleMusic = "\(bundlePath)/Musics/\(fileName)"
            if FileManager.default.fileExists(atPath: bundleMusic) {
                documentsPath = bundleMusic
                musicDir = "\(bundlePath)/Musics"
                print("从应用程序bundle加载音乐: \(bundleMusic)")
            }
        }
        
        if !FileManager.default.fileExists(atPath: documentsPath) {
            print("Failed to find music file: \(fileName) at path: \(documentsPath)")
            print("Trying to find a similar file...")
            
            do {
                var files = [String]()
                var bundleMusicsPath: String? = nil
                
                // 先尝试从bundle中查找
                if let bundlePath = Bundle.main.resourcePath {
                    bundleMusicsPath = "\(bundlePath)/Musics"
                    
                    if FileManager.default.fileExists(atPath: bundleMusicsPath!) {
                        if let bundleFiles = try? FileManager.default.contentsOfDirectory(atPath: bundleMusicsPath!) {
                            files = bundleFiles
                            musicDir = bundleMusicsPath!
                            print("使用App Bundle中的音乐目录: \(bundleMusicsPath!)")
                        }
                    } else {
                        // 如果失败，则使用原始路径
                        files = try FileManager.default.contentsOfDirectory(atPath: musicDir)
                        print("使用原始音乐目录: \(musicDir)")
                    }
                }
                
                let musicFiles = files.filter { $0.hasSuffix(".mp3") }
                print("Found \(musicFiles.count) music files")
                
                // 从文件名提取当前小时和天气
                let hourComponents = fileName.components(separatedBy: "：")
                let currentHour = hourComponents.first?.trimmingCharacters(in: .letters) ?? ""
                let isPM = fileName.contains("p.m.")
                
                // 匹配当前小时和天气条件
                let matchingFiles = musicFiles.filter { file in
                    return file.contains("\(currentHour)：") && 
                           file.contains(isPM ? "p.m." : "a.m.") && 
                           file.contains("(\(currentWeather.rawValue))")
                }
                
                if let bestMatch = matchingFiles.first {
                    print("Found matching file: \(bestMatch)")
                    playMusicWithPath("\(musicDir)/\(bestMatch)")
                    return
                } else {
                    // 如果没有完全匹配，就只匹配天气条件
                    let weatherMatchingFiles = musicFiles.filter { file in
                        return file.contains("(\(currentWeather.rawValue))")
                    }
                    
                    if let weatherMatch = weatherMatchingFiles.first {
                        print("Found weather matching file: \(weatherMatch)")
                        playMusicWithPath("\(musicDir)/\(weatherMatch)")
                        return
                    } else {
                        // 最后尝试任何音乐
                        if let anyMusic = musicFiles.first {
                            print("Using any available music: \(anyMusic)")
                            playMusicWithPath("\(musicDir)/\(anyMusic)")
                            return
                        }
                    }
                }
            } catch {
                print("Error listing directory: \(error)")
            }
            return
        }
        
        playMusicWithPath(documentsPath)
    }
    
    private func playMusicWithPath(_ path: String) {
        let fileURL = URL(fileURLWithPath: path)
        
        print("Playing music from: \(path)")
        
        do {
            player = try AVAudioPlayer(contentsOf: fileURL)
            player?.volume = volume // Use current volume setting
            player?.numberOfLoops = isLooping ? -1 : 0 // Set looping based on user preference
            player?.prepareToPlay()
            
            if isPlaying {
                player?.play()
            }
            
            // Fade in
            if isPlaying {
                let fadeInTime = 1.0 // 1 second fade in
                let fadeInterval = 0.1
                let startVolume = volume * 0.1
                let targetVolume = volume
                let volumeIncrement = (targetVolume - startVolume) / Float(fadeInTime / fadeInterval)
                
                player?.volume = startVolume
                
                var fadeInTimer: Timer?
                fadeInTimer = Timer.scheduledTimer(withTimeInterval: fadeInterval, repeats: true) { timer in
                    if let player = self.player, player.volume < targetVolume - volumeIncrement {
                        player.volume += volumeIncrement
                    } else {
                        if let player = self.player {
                            player.volume = targetVolume
                        }
                        fadeInTimer?.invalidate()
                    }
                }
            }
        } catch {
            print("Error playing music: \(error.localizedDescription)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
