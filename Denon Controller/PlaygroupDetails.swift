//  Copyright (c) 2017 Bartosz Przybylski

import Foundation

struct MediaDetails {
	var name: String
	var album: String
	var image_url: String
}

class PlaygroupDetails {

	public static let PDPlaygroupDetailsGathered = Notification.Name("PDPlaygroupDetailsGathered")

	let deviceConn: DeviceConnection

	var playgroup : PlayGroup?

	init(deviceConnection: DeviceConnection) {
		self.deviceConn = deviceConnection
	}

	func get(playgroup: PlayGroup) {
		let stateOp = GetPlaystateOperation(deviceConnection: deviceConn)
		stateOp.get(group: playgroup) { (stateData) in
			let stateJson = try? JSONSerialization.jsonObject(with: stateData, options: []) as! [String : AnyObject]
			if stateJson != nil, let heos = stateJson?["heos"] as? [String : String], heos["result"] == "success" {
				let stateOptions = Utils.extractOptions(message: heos["message"]!)
				let volumeOp = GetGroupVolumeOperation(deviceConnection: self.deviceConn)
				volumeOp.get(group: playgroup, callback: { (volumeData) in
					let volumeJson = try? JSONSerialization.jsonObject(with: volumeData, options: []) as! [String : AnyObject]
					if volumeJson != nil, let heos = volumeJson?["heos"] as? [String : String], heos["result"] == "success" {
						let volumeOptions = Utils.extractOptions(message: heos["message"]!)
						NotificationCenter.default.post(name: PlaygroupDetails.PDPlaygroupDetailsGathered, object: nil, userInfo: ["playgroup": playgroup, "playstate": Playstate(rawValue:stateOptions["state"]!)!, "volume": Int(volumeOptions["level"]!)!])
					}
				})
			}
		}
	}
}
