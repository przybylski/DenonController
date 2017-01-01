//  Copyright (c) 2017 Bartosz Przybylski

import Foundation

protocol ConfigurationFetcherCallback {
	func configFetcherError(err : String)
	func configFetchedSuccessfully(groups : [PlayGroup], players: [PlayerDetails])
}

class ConfigurationFetcher {

	let deviceConnection : DeviceConnection
	let getGroupsOperation : GetGroupsOperation?
	let getPlayersOperation: GetPlayersOperation?

	let operationTag = "ConfigurationFetcher".hashValue

	init(deviceIP : String) {
		self.deviceConnection = DeviceConnection()
		self.deviceConnection.connect(toHost: deviceIP, port: Constants.denonCliPort)

		self.getGroupsOperation = GetGroupsOperation(deviceConnection: self.deviceConnection)
		self.getPlayersOperation = GetPlayersOperation(deviceConnection: self.deviceConnection)
	}

	func getConfiguration(callback : ConfigurationFetcherCallback) {
		self.getGroupsOperation?.get(callback: { (groupData) in
			if let groupsHeosResp = self.getHeosBody(data: groupData) {

				if groupsHeosResp["result"] == "success" {
					self.getPlayersOperation?.get(callback: { (playersData) in
						if let playersHeosResp = self.getHeosBody(data: playersData) {
							if playersHeosResp["result"] == "success" {
								let groupPayload = self.getPayloadBody(data: groupData)
								let playersPayload = self.getPayloadBody(data: playersData)

								self.parseGroupsAndPlayser(groups: groupPayload, players: playersPayload, callback: callback)

							} else {
								callback.configFetcherError(err: "Failed players response from device: \(playersHeosResp["message"])")
							}

						} else {
							callback.configFetcherError(err: "Unknown error occurred on players fetching")
						}
					})
				} else {
					callback.configFetcherError(err: "Failed group response from device: \(groupsHeosResp["message"])")
				}

			} else {
				callback.configFetcherError(err: "Unknown error occurred on groups fetching")
			}


		})
	}

	private func getHeosBody(data: Data) -> [String : String]? {
		let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
		if jsonObject != nil, let jO = jsonObject as? [String : Any], let e = jO["heos"] as? [String : String] {
			return e
		}
		return nil
	}

	private func getPayloadBody(data: Data) -> Any? {
		let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
		if jsonObject != nil, let jO = jsonObject as? [String : Any] {
			return jO["payload"]
		}
		return nil
	}

	private func parseGroupsAndPlayser(groups : Any?, players: Any?, callback: ConfigurationFetcherCallback) {
		var playgroups = [PlayGroup]()
		if let gg = groups as? [[String : Any]] {
			for g in gg {
				let name = g["name"] as! String
				let gid = g["gid"] as! Int
				let p = g["players"] as! [[String : Any]]
				playgroups.append(PlayGroup(name: name, gid: gid, members: parseGroupMembers(players: p)))
			}
		}

		var allPlayers = [PlayerDetails]()
		if let pp = players as? [[String : Any]] {
			for p in pp {
				let name = p["name"] as! String
				let pid = p["pid"] as! Int
				let gid = p["gid"] as? Int
				let ip = p["ip"] as! String
				allPlayers.append(PlayerDetails(name: name, pid: pid, gid: gid, ip: ip))
			}
		}

		callback.configFetchedSuccessfully(groups: playgroups, players: allPlayers)
	}

	private func parseGroupMembers(players: [[String : Any]]) -> [PlaygroupMember] {
		var result = [PlaygroupMember]()
		for p in players {
			let name = p["name"] as! String
			let pid = p["pid"] as! Int
			let role = p["role"] as! String
			result.append(PlaygroupMember(name: name, pid: pid, role: role))
		}
		return result
	}

}
