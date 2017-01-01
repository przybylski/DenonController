//  Copyright (c) 2017 Bartosz Przybylski

import Foundation
import CocoaAsyncSocket

protocol DeviceConnectionDelegate {
	func dataRead(data : Data)
}

class DeviceConnection : NSObject, GCDAsyncSocketDelegate {

	private var delegateMap : [Int: DeviceConnectionDelegate] = [:]
	private var socket : GCDAsyncSocket?

	func connect(toHost: String, port: Int) {
		do {
			socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
			try socket?.connect(toHost: toHost, onPort: UInt16(port))
		} catch {
			print("Error while connecting \(error)")
		}
	}

	func disconnect() {
		if let s = socket {
			s.disconnect()
			socket = nil
		}
	}

	func isConnected() -> Bool {
		if let s = socket {
			return s.isConnected
		}
		return false
	}

	func add(delegate: DeviceConnectionDelegate, forTag tag: Int) {
		delegateMap[tag] = delegate
	}

	func removeDelegate(forTag tag: Int) {
		delegateMap.removeValue(forKey: tag)
	}

	func writeData(data: Data, tag: Int) {
		if let s = socket {
			s.write(data, withTimeout: -1, tag: tag)
		}
	}

	func readData(tag: Int) {
		if let s = socket {
			s.readData(withTimeout: -1, tag: tag)
		}
	}

	func writeReadData(data: Data, withTag tag: Int) {
		if let s = socket {
			s.write(data, withTimeout: -1, tag: tag)
			s.readData(withTimeout: -1, tag: tag)
		}
	}

	internal func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
		print("Socket disconnected err:\(err)")
	}

	internal func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
		if let d = delegateMap[tag] {
			d.dataRead(data: data)
		}
	}
}
