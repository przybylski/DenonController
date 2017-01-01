//  Copyright (c) 2017 Bartosz Przybylski

class GetGroupsOperation : GenericOperation {

	override init(deviceConnection: DeviceConnection) {
		super.init(deviceConnection: deviceConnection)
	}

	override func operationTag() -> Int { return "GetGroupsOperation".hashValue }
	override func operationUrl() -> String { return "group/get_groups" }

	func get(callback: OperationCallback?) {
		super.invoke(data: [:], callback: callback)
	}
}
