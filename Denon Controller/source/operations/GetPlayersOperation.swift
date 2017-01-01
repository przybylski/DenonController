//  Copyright (c) 2017 Bartosz Przybylski

class GetPlayersOperation : GenericOperation {

	override init(deviceConnection: DeviceConnection) {
		super.init(deviceConnection: deviceConnection)
	}

	override func operationTag() -> Int { return "GetPlayersOperation".hashValue }
	override func operationUrl() -> String { return "player/get_players" }

	func get(callback: OperationCallback?) {
		super.invoke(data: [:], callback: callback)
	}
}
