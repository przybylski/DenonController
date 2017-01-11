//  Copyright (c) 2017 Bartosz Przybylski

import Cocoa

class MediaControlBar : NSView {

	public class Notifications {
		typealias NCN = Notification.Name

		static let MCPrevButtonPressed = NCN("MCPrevButtonPressed")
		static let MCPlayPauseButtonPressed = NCN("MCPlayPauseButtonPressed")
		static let MCNextButtonPressed = NCN("MCNextButtonPressed")
		static let MCVolumeChanged = NCN("MCVolumeChanged")
		static let MCGroupChanged = NCN("MCGroupChanged")
	}

	var playButton : NSButton?
	var prevButton : NSButton?
	var nextButton : NSButton?
	var volumeControl : VolumeControlBarButton?
	var settingButton : SettingsMenuBarButton?

	var statusItem : NSStatusItem?

	static private let iconWidth : CGFloat = 25

	init(statusItem: NSStatusItem) {
		let itemHeight = NSStatusBar.system().thickness
		let itemWidth = statusItem.length
		let itemRect = CGRect(x: 0, y: 0, width: itemWidth, height: itemHeight)
		super.init(frame: itemRect)

		self.statusItem = statusItem;
		NotificationCenter.default.addObserver(self, selector: #selector(MediaControlBar.userDidChangePlaygroup), name: Notifications.MCGroupChanged, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(MediaControlBar.groupVolumeChanged), name: ChangeEventsListener.ChangeEventGroupVolumeChanged, object: nil)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	static public func getNumberOfElements() -> Int {
		return 5
	}

	static public func getOverallWidth() -> CGFloat {
		return iconWidth * CGFloat(getNumberOfElements())
	}

	func initSubviews() {
		prevButton = self.newButton(title: "prev", image: NSImage(named: "icon-prev")!, target: self, action: #selector(MediaControlBar.buttonClicked))
		insertButton(btn: prevButton!, after: self)
		prevButton?.isEnabled = false

		playButton = self.newButton(title: "play", image: NSImage(named:"icon-play")!, target: self, action: #selector(MediaControlBar.buttonClicked))
		insertButton(btn: playButton!, after: prevButton!)
		playButton?.isEnabled = false

		nextButton = self.newButton(title: "next", image: NSImage(named: "icon-next")!, target: self, action: #selector(MediaControlBar.buttonClicked))
		insertButton(btn: nextButton!, after: playButton!)
		nextButton?.isEnabled = false

		volumeControl = VolumeControlBarButton(statusItem: statusItem)
		insertButton(btn: volumeControl!, after: nextButton!)
		volumeControl?.isEnabled = false

		settingButton = SettingsMenuBarButton(statusItem: statusItem!)
		insertButton(btn: settingButton!, after: volumeControl!)
	}

	func setVolume(volume: Int) {
		volumeControl?.volume = volume
	}

	func setPlaystate(playstate : Playstate) {
		if playstate == .play {
			playButton?.image = NSImage(named: "icon-pause")
		} else {
			playButton?.image = NSImage(named: "icon-play")
		}
	}

	func buttonClicked(btn : NSButton) {
		let nc = NotificationCenter.default

		if prevButton == btn {
			nc.post(name: Notifications.MCPrevButtonPressed, object: nil)
		} else if playButton == btn {
			nc.post(name: Notifications.MCPlayPauseButtonPressed, object: nil)
		} else if nextButton == btn {
			nc.post(name: Notifications.MCNextButtonPressed, object: nil)
		}
	}

	private func newButton(title: String, image: NSImage?, target: AnyObject, action: Selector?) -> NSButton {
		let btn = NSButton()
		btn.title = title
		btn.image = image!
		btn.target = target
		btn.action = action
		btn.imageScaling = .scaleProportionallyDown

		return btn
	}


	private func insertButton(btn : NSButton, after: NSView) {
		let systemBarThickness = NSStatusBar.system().thickness

		btn.imagePosition = .imageOnly
		btn.isBordered = false
		btn.translatesAutoresizingMaskIntoConstraints = false
		let afterAttribute = ( (after is NSButton) ? NSLayoutAttribute.trailing : NSLayoutAttribute.leading)
		addConstraints([
			NSLayoutConstraint(item: btn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: systemBarThickness),
			NSLayoutConstraint(item: btn, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: MediaControlBar.iconWidth),
			NSLayoutConstraint(item: btn, attribute: .leading, relatedBy: .equal, toItem: after, attribute: afterAttribute, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: btn, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
			])
		addSubview(btn)
	}

	@objc func userDidChangePlaygroup(notification: Notification) {
		prevButton?.isEnabled = true
		playButton?.isEnabled = true
		nextButton?.isEnabled = true
		volumeControl?.isEnabled = true
	}

	@objc func groupVolumeChanged(notification: Notification) {
		if let userInfo = notification.userInfo, let message = userInfo["message"] as? String {
			let opts = Utils.extractOptions(message: message)
			if let volumeLevel = opts["level"], let levelInt = Int(volumeLevel) {
				if volumeControl?.volume != levelInt {
					DispatchQueue.main.async {
						self.volumeControl?.volume = levelInt
					}
				}
			}
		}
	}
}
