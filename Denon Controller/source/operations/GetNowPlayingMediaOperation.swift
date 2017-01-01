//  Copyright (c) 2017 Bartosz Przybylski

class GetNowPlayingMediaOperation : GenericOperation {

	override init(deviceConnection: DeviceConnection) {
		super.init(deviceConnection: deviceConnection)
	}

	override func operationTag() -> Int { return "GetNowPlayingMediaOperation".hashValue }
	override func operationUrl() -> String { return "player/get_now_playing_media" }

	func getMedia(group: PlayGroup, callback: OperationCallback?) {
		super.invoke(data: ["pid" : "\(group.gid)"], callback: callback)
	}
}
