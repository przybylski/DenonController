//  Copyright (c) 2017 Bartosz Przybylski

import Cocoa

class SettingsMenuBarButton : NSButton {

	let statusItem : NSStatusItem?
	var previousCheckedMenu : NSMenuItem? = nil
	let displayMenu = NSMenu()

	init(statusItem : NSStatusItem) {
		self.statusItem = statusItem
		super.init(frame: NSRect.zero)
		initView()
	}
	
	required init?(coder: NSCoder) {
		self.statusItem = nil
		super.init(coder: coder)
	}

	private func initView() {
		self.imageScaling = .scaleProportionallyDown
		self.image = NSImage(named: "icon-speaker")
		self.target = self
		self.action = #selector(settingsButtonPressed)

		// construct Menu
		let groupsMenuItem = NSMenuItem(title: "Groups", action: nil, keyEquivalent: "")
		let groupsMenu = NSMenu()

		if let pg = DeviceStore.getInstance().getPlaygroups() {
			for p in pg {
				groupsMenu.addItem(PlaygroupMenuItem(playgroup: p, target: self))
			}
		}
		groupsMenuItem.submenu = groupsMenu
		displayMenu.addItem(groupsMenuItem)
		displayMenu.addItem(NSMenuItem.separator())
		let quitOption = NSMenuItem(title: "Quit", action: #selector(SettingsMenuBarButton.quitClicked), keyEquivalent: "")
		quitOption.target = self
		displayMenu.addItem(quitOption)
	}

	public func settingsButtonPressed() {
		self.statusItem?.popUpMenu(self.displayMenu)
	}

	public func groupItemClicked(item: PlaygroupMenuItem) {
		if let pdm = previousCheckedMenu {
			pdm.state = 0
		}
		item.state = 1
		previousCheckedMenu = item
		NotificationCenter.default.post(name: MediaControlBar.Notifications.MCGroupChanged, object: nil, userInfo: ["playgroup": item.playgroup!])
	}

	public func quitClicked(item: NSMenuItem) {
		NSApp.terminate(self)
	}

	class PlaygroupMenuItem : NSMenuItem {
		let playgroup : PlayGroup?

		init(playgroup : PlayGroup, target: SettingsMenuBarButton) {
			self.playgroup = playgroup
			super.init(title: playgroup.name, action: #selector(SettingsMenuBarButton.groupItemClicked), keyEquivalent: "")
			self.target = target
		}
		
		required init(coder decoder: NSCoder) {
			playgroup = nil
			super.init(coder: decoder)
		}
	}

}
