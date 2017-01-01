//  Copyright (c) 2017 Bartosz Przybylski

class PlayPreviousOperation : GenericOperation {

	override init(deviceConnection: DeviceConnection) {
		super.init(deviceConnection: deviceConnection)
	}

	override func operationTag() -> Int { return "PlayPreviousOperation".hashValue }
	override func operationUrl() -> String { return "player/play_previous" }

	func playPrevious(playgroup: PlayGroup, callback: OperationCallback?) {
		super.invoke(data: ["pid": "\(playgroup.gid)"], callback: callback)
	}

}
