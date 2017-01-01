//  Copyright (c) 2017 Bartosz Przybylski

class PlayNextOperation: GenericOperation {

	override init(deviceConnection: DeviceConnection) {
		super.init(deviceConnection: deviceConnection)
	}

	override func operationTag() -> Int { return "PlayNextOperation".hashValue }
	override func operationUrl() -> String { return "player/play_next" }

	func playNext(playgroup: PlayGroup, callback: OperationCallback?) {
		super.invoke(data: ["pid": "\(playgroup.gid)"], callback: callback)
	}

}
