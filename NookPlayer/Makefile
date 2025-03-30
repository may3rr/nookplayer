
.PHONY: build clean install

APP_NAME = NookPlayer
BUILD_DIR = .build
INSTALL_DIR = $(HOME)/Applications

build:
	swift build -c release
	mkdir -p $(BUILD_DIR)/$(APP_NAME).app/Contents/MacOS
	mkdir -p $(BUILD_DIR)/$(APP_NAME).app/Contents/Resources
	cp .build/release/$(APP_NAME) $(BUILD_DIR)/$(APP_NAME).app/Contents/MacOS/
	cp Info.plist $(BUILD_DIR)/$(APP_NAME).app/Contents/
	cp -R Assets.xcassets $(BUILD_DIR)/$(APP_NAME).app/Contents/Resources/
	@echo "Application built at $(BUILD_DIR)/$(APP_NAME).app"

install: build
	mkdir -p $(INSTALL_DIR)
	cp -R $(BUILD_DIR)/$(APP_NAME).app $(INSTALL_DIR)/
	@echo "Application installed to $(INSTALL_DIR)/$(APP_NAME).app"

clean:
	rm -rf $(BUILD_DIR)
	swift package clean
