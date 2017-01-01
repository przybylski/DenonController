//  Copyright (c) 2017 Bartosz Przybylski

import Foundation

class SetGroupVolumeOperation: GenericOperation {

	override init(deviceConnection: DeviceConnection) {
		super.init(deviceConnection: deviceConnection)
	}

	override func operationTag() -> Int { return "SetGroupVolumeOperation".hashValue }
	override func operationUrl() -> String { return "group/set_volume" }

	func set(group: PlayGroup, volume: Int, callback: OperationCallback?) {
		super.invoke(data: ["gid" : "\(group.gid)", "level": "\(volume)"], callback: callback)
	}
}
