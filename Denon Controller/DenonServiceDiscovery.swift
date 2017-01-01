//  Copyright (c) 2017 Bartosz Przybylski

import Foundation
import CocoaAsyncSocket

protocol DenonServiceDiscoveryDelegate: class {
	func denonDeviceDiscovered(location : NSURL)
}

class DenonServiceDiscovery : NSObject, GCDAsyncUdpSocketDelegate {

	private var broadcastingSocket : GCDAsyncUdpSocket?
	private let ssdpAddress = "239.255.255.250"
	private let ssdpPort : UInt16 = 1900
	private let denonSsdpST = "urn:schemas-denon-com:device:ACT-Denon:1"

	weak var delegate : DenonServiceDiscoveryDelegate? = nil

	override init() {
		super.init()
	}

	public func discover() {
		let searchQueue =
			("M-SEARCH * HTTP/1.1\r\n" +
			"HOST: \(ssdpAddress):\(ssdpPort)\r\n" +
			"MAN: \"ssdp:discover\"\r\n" +
			"MX: 3\r\n" +
			"ST: \(denonSsdpST)\r\n" +
			"USER-AGENT: Denon Controller/1.0\r\n\r\n").data(using: String.Encoding.utf8)
		broadcastingSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
		broadcastingSocket!.send(searchQueue!, toHost: ssdpAddress, port: ssdpPort, withTimeout: 1, tag: 0)

		do {
			try broadcastingSocket?.bind(toPort: ssdpPort)
			try broadcastingSocket?.joinMulticastGroup(ssdpAddress)
			try broadcastingSocket?.beginReceiving()
		} catch {
			print("Error: \(error)")
		}
	}

	public func unbind() {
		if let bs = broadcastingSocket {
			do {
				try bs.leaveMulticastGroup(ssdpAddress)
				bs.close()
				broadcastingSocket = nil
			} catch {
				print("Error while unbinding \(error)")
			}
		}
	}

	func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
		if let message = NSString(data: data, encoding:String.Encoding.utf8.rawValue) {
			var httpMethodLine : String?
			var headers = [String: String]()
			let headersRegex = try? NSRegularExpression(pattern: "^([a-zA-Z0-9]+): *(.+)$", options: [.caseInsensitive, .anchorsMatchLines])
			print(message)
			message.enumerateLines({ (line, stop) in
				if httpMethodLine == nil {
					httpMethodLine = line
				} else {
					headersRegex?.enumerateMatches(in: line, options: [], range: NSRange(location:0, length: line.characters.count), using: { (resultOptional, flags, stop) in
						if let result = resultOptional, result.numberOfRanges == 3 {
							let key = (line as NSString).substring(with: result.rangeAt(1)).lowercased()
							let value = (line as NSString).substring(with: result.rangeAt(2))
							headers[key] = value
						}
					})
				}
			})

			if let httpLine = httpMethodLine {
				let st = headers["st"]
				if httpLine == "HTTP/1.1 200 OK" && st == denonSsdpST {
					if let d = delegate, let l = NSURL(string:headers["location"]!) {
						d.denonDeviceDiscovered(location: l)
					}
				}

			}
		}
	}

}
