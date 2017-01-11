//  Copyright (c) 2017 Bartosz Przybylski

import Cocoa

class VolumeControlBarButton : NSButton {

	var volume : Int = 100 {
		didSet(oldValue) {
			adjustVolumeIcon()
			if let vs = self.volumeSlider {
				vs.doubleValue = Double(volume)/100
			}
		}
	}
	var statusItem : NSStatusItem?
	var volumeSlider : NSSlider?

	init(statusItem : NSStatusItem?) {
		super.init(frame:CGRect.zero)
		self.statusItem = statusItem
		self.target = self
		self.action = #selector(volumeClicked)
		self.imageScaling = .scaleProportionallyDown
		self.imagePosition = .imageLeft
		self.image = NSImage(named: "icon-volume-mid")
		self.volumeSlider = NSSlider()
		self.volumeSlider?.minValue = 0.0
		self.volumeSlider?.maxValue = 1.0
		self.volumeSlider?.target = self
		self.volumeSlider?.action = #selector(VolumeControlBarButton.volumeChanged)
		self.volumeSlider!.isContinuous = false
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	func volumeClicked() {
		let menu = NSMenu()
		let menuItem = NSMenuItem()
		self.volumeSlider!.doubleValue = Double(self.volume)/100
		menuItem.view = self.volumeSlider!
		menu.addItem(menuItem)

		statusItem!.popUpMenu(menu);
	}

	func adjustVolumeIcon() {
		if (volume == 0) {
			self.image = NSImage(named: "icon-volume-mute")
		} else if (volume < 30) {
			self.image = NSImage(named: "icon-volume-low")
		} else if (volume < 60) {
			self.image = NSImage(named: "icon-volume-mid")
		} else {
			self.image = NSImage(named: "icon-volume-high")
		}
		self.toolTip = "Volume: \(self.volume)%"
	}

	public func volumeChanged(slider : NSSlider) {
		self.volume = Int(100*slider.doubleValue)
		NotificationCenter.default.post(name: MediaControlBar.Notifications.MCVolumeChanged, object: nil, userInfo: ["volume": self.volume])
	}

}
