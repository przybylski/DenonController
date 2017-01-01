//  Copyright (c) 2017 Bartosz Przybylski

import Cocoa

class ChangeEventsListener : DeviceConnectionDelegate {

	static let operationTag = "ChangeEventsListener".hashValue
	private let devConnection : DeviceConnection

	static let ChangeEventGroupAltered = Notification.Name("ChangeEventGroupAltered")
	static let ChangeEventPlayingMediaChanged = Notification.Name("ChangeEventPlayingMediaChanged")
	static let ChangeEventPlaystateChanged = Notification.Name("ChangeEventPlaystateChanged")
	static let ChangeEventGroupVolumeChanged = Notification.Name("ChangeEventGroupVolumeChanged")

	init(deviceAddress : String) {
		devConnection = DeviceConnection()
	}

	func connectToDevice(address: String) {
		if devConnection.isConnected() {
			// We will notify about deregistration but we won't wait for response, cruel
			let deregisterData = "heos://system/register_for_change_events?=enable=off\n\r".data(using: String.Encoding.ascii)
			devConnection.writeData(data: deregisterData!, tag: ChangeEventsListener.operationTag)
			devConnection.disconnect()
			devConnection.removeDelegate(forTag: ChangeEventsListener.operationTag)
		}
		devConnection.connect(toHost: address, port: Constants.denonCliPort)
		devConnection.add(delegate: self, forTag: ChangeEventsListener.operationTag)

		let writeData = "heos://system/register_for_change_events?enable=on\n\r".data(using: String.Encoding.ascii)
		devConnection.writeReadData(data: writeData!, withTag: ChangeEventsListener.operationTag)
	}

	internal func dataRead(data: Data) {
		if let message = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String {
			let lines = message.components(separatedBy: "\r\n")
			for line in lines {
				if line.isEmpty {
					continue
				}
				let jsonResp = try? JSONSerialization.jsonObject(with: line.data(using: String.Encoding.utf8)!, options: []) as! [String: Any]

				let heos = jsonResp!["heos"] as! [String: String]

				if !eventAddressedToCurrentGroup(heos: heos) {
					continue
				}

				switch heos["command"]! {
					case "system/register_for_change_events":
						if heos["result"] == "fail" {
							print("Failed to register for change events")
							devConnection.disconnect()
							return
						}
						break
					case "event/player_now_playing_changed":
						notify(name: ChangeEventsListener.ChangeEventPlayingMediaChanged, message: heos["message"]!)
						break
					case "event/player_state_changed":
						notify(name: ChangeEventsListener.ChangeEventPlaystateChanged, message: heos["message"]!)
						break
					case "event/groups_changed": fallthrough
					case "event/players_changed":
						notify(name: ChangeEventsListener.ChangeEventGroupAltered, message: heos["message"]!)
						break
					case "event/group_volume_changed":
						notify(name: ChangeEventsListener.ChangeEventGroupVolumeChanged, message: heos["message"]!)
						break
					case "event/player_volume_changed": fallthrough
					case "event/player_queue_changed": fallthrough
					case "event/repeat_mode_changed": fallthrough
					case "event/player_now_playing_progress":
						// ignore
						break
					default:
						print("incoming unhandled command:\(heos["command"]!)")
				}
			}
		}

		devConnection.readData(tag: ChangeEventsListener.operationTag)
	}

	private func notify(name: Notification.Name, message: String) {
		NotificationCenter.default.post(name: name, object: nil, userInfo: ["message" : message])
	}

	private func eventAddressedToCurrentGroup(heos: [String : String]) -> Bool{
		if let message = heos["message"] {
			let opts = Utils.extractOptions(message: message)
			let currentGroup = DeviceStore.getInstance().getCurrentPlaygroup()
			let leader = DeviceStore.getInstance().getCurrentGroupLeader()

			if let strPid = opts["pid"], let pid = Int(strPid), pid == leader?.pid {
				return true
			}

			if let strGid = opts["gid"], let gid = Int(strGid), gid == currentGroup?.gid {
				return true
			}
		}
		return false
	}

}
