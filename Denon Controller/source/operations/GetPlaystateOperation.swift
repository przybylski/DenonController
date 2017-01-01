//  Copyright (c) 2017 Bartosz Przybylski

class GetPlaystateOperation : GenericOperation {

	override init(deviceConnection: DeviceConnection) {
		super.init(deviceConnection: deviceConnection)
	}

	override func operationTag() -> Int { return "GetPlaystateOperation".hashValue }
	override func operationUrl() -> String { return "player/get_play_state" }

	func get(group: PlayGroup, callback: OperationCallback?) {
		super.invoke(data: ["pid": "\(group.gid)"], callback: callback)
	}
}
