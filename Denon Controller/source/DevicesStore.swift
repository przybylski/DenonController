//  Copyright (c) 2017 Bartosz Przybylski

import Foundation

class DeviceStore : NSObject {

	static private var instance : DeviceStore?

	static public let DSDataSynchronized = Notification.Name("DSDataSynchronized")

	private var playgroups : [PlayGroup]?
	private var players : [PlayerDetails]?
	private var currentPlaygroup : PlayGroup?

	private override init() {
		super.init()

		NotificationCenter.default.addObserver(self, selector: #selector(DeviceStore.groupsAltered), name: ChangeEventsListener.ChangeEventGroupAltered, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(DeviceStore.selectedGroupChanged), name: MediaControlBar.Notifications.MCGroupChanged, object: nil)
	}

	static func getInstance() -> DeviceStore {
		if instance == nil {
			instance = DeviceStore()
		}
		return DeviceStore.instance!
	}

	func getPlaygroups() -> [PlayGroup]? {
		return self.playgroups
	}

	func getCurrentPlaygroup() -> PlayGroup? {
		return self.currentPlaygroup
	}

	func getCurrentGroupLeader() -> PlayerDetails? {
		if self.currentPlaygroup == nil {
			return nil
		}

		var leaderId = -1
		for p in self.currentPlaygroup!.members {
			if p.role == "leader" {
				leaderId = p.pid
				break
			}
		}

		if leaderId == -1 {
			fatalError("No leader in group")
		}

		for p in players! {
			if p.pid == leaderId {
				return p
			}
		}

		fatalError("No requested player in player list")
	}

	func setInitial(groups : [PlayGroup], andPlayers players: [PlayerDetails]) {
		self.playgroups = groups
		self.players = players
	}

	internal func groupsAltered(notification : Notification) {

	}

	internal func selectedGroupChanged(notification : Notification) {
		self.currentPlaygroup = notification.userInfo!["playgroup"] as? PlayGroup
		NotificationCenter.default.post(name: DeviceStore.DSDataSynchronized, object: nil)
	}

}
