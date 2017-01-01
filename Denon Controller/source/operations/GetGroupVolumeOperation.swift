//  Copyright (c) 2017 Bartosz Przybylski

class GetGroupVolumeOperation : GenericOperation {

	override init(deviceConnection: DeviceConnection) {
		super.init(deviceConnection: deviceConnection)
	}

	override func operationTag() -> Int { return "GetGroupVolumeOperation".hashValue }
	override func operationUrl() -> String { return "player/get_volume" }

	func get(group: PlayGroup, callback: OperationCallback?) {
		super.invoke(data: ["gid": "\(group.gid)"], callback: callback)
	}
}
