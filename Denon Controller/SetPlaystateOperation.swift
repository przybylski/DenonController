//  Copyright (c) 2017 Bartosz Przybylski

public enum Playstate: String {
	case play = "play"
	case pause = "pause"
	case stop = "stop"
	case unknown = "unknown"
}

class SetPlaystateOperation : GenericOperation {

	override init(deviceConnection : DeviceConnection) {
		super.init(deviceConnection: deviceConnection)
	}

	override func operationTag() -> Int { return "PlaystateOperation".hashValue }
	override func operationUrl() -> String { return "player/set_play_state" }

	public func setPlaystate(group : PlayGroup, playstate: Playstate, callback: OperationCallback?) {
		super.invoke(data: ["pid": "\(group.gid)", "state": "\(playstate)"], callback: callback)
	}

}
