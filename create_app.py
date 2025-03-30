#!/usr/bin/env python3
import os
import shutil
import subprocess
import sys

# 项目目录
project_dir = "/Users/jackielyu/Downloads/代码项目/nookplayer"
app_name = "NookPlayer"

# 创建应用包结构
app_dir = f"{project_dir}/{app_name}.app"
contents_dir = f"{app_dir}/Contents"
macos_dir = f"{contents_dir}/MacOS"
resources_dir = f"{contents_dir}/Resources"

# 删除现有的应用包（如果存在）
if os.path.exists(app_dir):
    shutil.rmtree(app_dir)

# 创建目录结构
os.makedirs(macos_dir, exist_ok=True)
os.makedirs(resources_dir, exist_ok=True)

# 编译Swift文件
print("编译Swift文件...")
os.chdir(f"{project_dir}/NookPlayer")
compile_cmd = [
    "swiftc",
    "-o", f"{macos_dir}/{app_name}",
    "NookPlayer.swift",
    "ContentView.swift",
    "-framework", "AppKit",
    "-framework", "SwiftUI",
    "-framework", "AVFoundation"
]
result = subprocess.run(compile_cmd, capture_output=True, text=True)
if result.returncode != 0:
    print(f"编译失败：{result.stderr}")
    sys.exit(1)
else:
    print("编译成功！")

# 创建基本的Info.plist
info_plist = f"""\
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>{app_name}</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.nookplayer.app</string>
    <key>CFBundleName</key>
    <string>{app_name}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSUIElement</key>
    <false/>
</dict>
</plist>
"""

with open(f"{contents_dir}/Info.plist", "w") as f:
    f.write(info_plist)
print("已创建Info.plist")

# 复制Assets到Resources目录
if os.path.exists(f"{project_dir}/NookPlayer/Assets.xcassets"):
    shutil.copytree(
        f"{project_dir}/NookPlayer/Assets.xcassets", 
        f"{resources_dir}/Assets.xcassets",
        dirs_exist_ok=True
    )
    print("已复制Assets.xcassets")

# 复制音乐文件到应用程序包中（可选）
musics_dir = f"{resources_dir}/Musics"
if os.path.exists(f"{project_dir}/Resources/Musics"):
    shutil.copytree(
        f"{project_dir}/Resources/Musics", 
        musics_dir,
        dirs_exist_ok=True
    )
    print("已复制音乐文件")

# 使用bar.png作为图标
bar_png = f"{project_dir}/bar.png"
if os.path.exists(bar_png):
    # 简单复制作为应用图标
    icon_dir = f"{resources_dir}"
    shutil.copy(bar_png, f"{icon_dir}/AppIcon.png")
    print(f"已复制图标: {icon_dir}/AppIcon.png")

print(f"\n应用程序包已创建: {app_dir}")
print("你可以将它拖到Applications文件夹安装，或者直接双击运行")
