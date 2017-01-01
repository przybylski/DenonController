//  Copyright (c) 2017 Bartosz Przybylski

import Foundation

typealias OperationCallback = (Data)->Void

class GenericOperation : NSObject, DeviceConnectionDelegate {
	internal var devConn: DeviceConnection
	internal var callback: OperationCallback?

	init(deviceConnection: DeviceConnection) {
		devConn = deviceConnection
		super.init()
	}

	func operationTag() -> Int { preconditionFailure("unimplemented operationTag") }
	func operationUrl() -> String { preconditionFailure("unimplemented operationUrl") }

	public func invoke(data: [String: String], callback: OperationCallback?) {
		devConn.add(delegate: self, forTag: operationTag())
		self.callback = callback
		var callUri = "heos://\(operationUrl())?"

		for (key, value) in data {
			let escaped = value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
			callUri.append(key + "=" + escaped + "&")
		}
		
		callUri.append("\n\r")

		let writeData = callUri.data(using: String.Encoding.ascii)
		devConn.writeReadData(data: writeData!, withTag: operationTag())
	}

	internal func dataRead(data: Data) {
		print(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)
		let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
		let heos = json?["heos"] as! [String : String]
		if heos["command"] != operationUrl() {
			var i = 1
			i += 1
		}

		if let cb = callback {
			cb(data)
		}
		devConn.removeDelegate(forTag: operationTag())
	}

}
