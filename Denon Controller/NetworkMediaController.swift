//  Copyright (c) 2017 Bartosz Przybylski

import Foundation

class NetworkMediaController {

	let factory : OperationsFactory
	var currentPlaygroup : PlayGroup?
	var currentPlaystate : Playstate?

	init(factory: OperationsFactory) {
		self.factory = factory
		let nc = NotificationCenter.default
		typealias selfType = NetworkMediaController
		typealias mBarN = MediaControlBar.Notifications
		nc.addObserver(self, selector: #selector(selfType.mediaPrevButtonPressed), name: mBarN.MCPrevButtonPressed, object: nil)
		nc.addObserver(self, selector: #selector(selfType.mediaPlayPauseButtonPressed), name: mBarN.MCPlayPauseButtonPressed, object: nil)
		nc.addObserver(self, selector: #selector(selfType.mediaNextButtonPressed), name: mBarN.MCNextButtonPressed, object: nil)
		nc.addObserver(self, selector: #selector(selfType.mediaVolumeChanged), name: mBarN.MCVolumeChanged, object: nil)
		nc.addObserver(self, selector: #selector(selfType.userDidChangePlaygroup), name: mBarN.MCGroupChanged, object: nil)

		nc.addObserver(self, selector: #selector(selfType.playgroupDetailGathered), name: PlaygroupDetails.PDPlaygroupDetailsGathered, object: nil)
	}

	@objc func mediaPrevButtonPressed(notification: Notification) {
		let op = factory.get(operation: .PlayPrevious)
		op.invoke(data: ["pid" : "\(self.currentPlaygroup!.gid)"], callback: nil)
	}

	@objc func mediaNextButtonPressed(notification: Notification) {
		let op = factory.get(operation: .PlayNext)
		op.invoke(data: ["pid" : "\(self.currentPlaygroup!.gid)"], callback: nil)
	}

	@objc func mediaPlayPauseButtonPressed(notification: Notification) {
		var nextPlaystate = Playstate.play
		if currentPlaystate == .play {
			nextPlaystate = .pause
		}
		let op = factory.get(operation: .SetPlaystate)
		op.invoke(data: ["pid": "\(self.currentPlaygroup!.gid)", "state": (nextPlaystate == .pause ? "pause" : "play")], callback: nil)
		currentPlaystate = nextPlaystate
	}

	@objc func mediaVolumeChanged(notification: Notification) {
		let volume = notification.userInfo!["volume"] as! Int
		let op = factory.get(operation: .SetGroupVolume)
		op.invoke(data: ["gid" : "\(self.currentPlaygroup!.gid)", "level": "\(volume)"], callback: nil)
	}

	@objc func userDidChangePlaygroup(notification: Notification) {
		self.currentPlaygroup = notification.userInfo?["playgroup"] as? PlayGroup
	}

	@objc func playgroupDetailGathered(notification: Notification) {
		let ud = notification.userInfo!
		currentPlaystate = ud["playstate"] as? Playstate
	}

}
