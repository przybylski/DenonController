//  Copyright (c) 2017 Bartosz Przybylski

import Foundation

class OperationsFactory {

	public enum Operation {
		case PlayNext
		case PlayPrevious
		case SetGroupVolume
		case SetPlaystate
		case GetNowPlayingMedia
	}

	private let playNext : PlayNextOperation
	private let playPrev : PlayPreviousOperation
	private let setGroupVolume : SetGroupVolumeOperation
	private let setPlaystate : SetPlaystateOperation
	private let getNowPlayingMedia : GetNowPlayingMediaOperation

	private var devConnection : DeviceConnection

	init(deviceConnection: DeviceConnection) {
		devConnection = deviceConnection
		playNext = PlayNextOperation(deviceConnection: devConnection)
		playPrev = PlayPreviousOperation(deviceConnection: devConnection)
		setGroupVolume = SetGroupVolumeOperation(deviceConnection: devConnection)
		setPlaystate = SetPlaystateOperation(deviceConnection: devConnection)
		getNowPlayingMedia = GetNowPlayingMediaOperation(deviceConnection: devConnection)
	}

	func setNewDeviceConnection(devConnection: DeviceConnection) {
		self.devConnection = devConnection
		self.playNext.devConn = devConnection
		self.playPrev.devConn = devConnection
		self.setGroupVolume.devConn = devConnection
		self.setPlaystate.devConn = devConnection
		self.getNowPlayingMedia.devConn = devConnection
	}

	func get(operation: Operation) -> GenericOperation {
		switch operation {
			case .PlayNext:
				return playNext
			case .PlayPrevious:
				return playPrev
			case .SetGroupVolume:
				return setGroupVolume
			case .SetPlaystate:
				return setPlaystate
			case .GetNowPlayingMedia:
				return getNowPlayingMedia
		}
	}


}
