//  Copyright (c) 2017 Bartosz Przybylski

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, DenonServiceDiscoveryDelegate, ConfigurationFetcherCallback {

	let serviceDiscovery = DenonServiceDiscovery()
	var statusItem : NSStatusItem?

	var primaryDenonDevice : NSURL? = nil
	var deviceConnection : DeviceConnection? = nil

	var track : MediaControlBar?
	var netMediaController : NetworkMediaController?

	var eventsListener : ChangeEventsListener?

	var configurationFetcher : ConfigurationFetcher?

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		serviceDiscovery.delegate = self
		serviceDiscovery.discover()

		let nc = NotificationCenter.default;
		nc.addObserver(self, selector: #selector(AppDelegate.newGroupSelected), name: DeviceStore.DSDataSynchronized, object: nil)
		nc.addObserver(self, selector: #selector(AppDelegate.detailsGathered), name: PlaygroupDetails.PDPlaygroupDetailsGathered, object: nil)

		nc.addObserver(self, selector: #selector(AppDelegate.playingMediaChanged), name: ChangeEventsListener.ChangeEventPlayingMediaChanged, object: nil)
		nc.addObserver(self, selector: #selector(AppDelegate.playstateChanged), name: ChangeEventsListener.ChangeEventPlaystateChanged, object: nil)
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		serviceDiscovery.unbind()
	}

	func denonDeviceDiscovered(location: NSURL) {
		if primaryDenonDevice != nil {
			return
		}
		primaryDenonDevice = location
		serviceDiscovery.unbind()

		deviceConnection = DeviceConnection()
		deviceConnection?.connect(toHost: location.host!, port: Constants.denonCliPort)

		eventsListener = ChangeEventsListener(deviceAddress: location.host!)

		netMediaController = NetworkMediaController(factory: OperationsFactory(deviceConnection: deviceConnection!))
		configurationFetcher = ConfigurationFetcher(deviceIP: location.host!)
		configurationFetcher?.getConfiguration(callback: self)
	}

	var pd : PlaygroupDetails?

	func newGroupSelected(notification: Notification) {
		let selectedPlaygroup = DeviceStore.getInstance().getCurrentPlaygroup()
		if pd == nil {
			pd = PlaygroupDetails(deviceConnection: deviceConnection!)
		}
		pd?.get(playgroup: selectedPlaygroup!)
		let groupLeader = DeviceStore.getInstance().getCurrentGroupLeader()

		eventsListener?.connectToDevice(address: groupLeader!.ip)
	}

	func setupStatusBar() {
		statusItem = NSStatusBar.system().statusItem(withLength: MediaControlBar.getOverallWidth())
		let item = statusItem!
		track = MediaControlBar(statusItem: item)
		track?.initSubviews()
		item.view = track
		item.highlightMode = true
	}

	var currentplaystate : Playstate?

	@objc func detailsGathered(notification: Notification) {
		let ud = notification.userInfo!
		let playstate = ud["playstate"] as! Playstate
		let volume = ud["volume"] as! Int

		track?.setVolume(volume: volume)
		track?.setPlaystate(playstate: playstate)
		currentplaystate = playstate
	}

	internal func playingMediaChanged(notification: Notification) {
		let op = GetNowPlayingMediaOperation(deviceConnection: deviceConnection!)

		op.getMedia(group: DeviceStore.getInstance().getCurrentPlaygroup()!, callback: { (data) in
			let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
			let payload = json?["payload"] as! [String: Any]
			let songName = payload["song"] as! String
			let artist = payload["artist"] as! String
			let album = payload["album"] as! String
			let imageUrl = payload["image_url"] as! String

			let userNotification = NSUserNotification.init()
			userNotification.title = songName
			userNotification.informativeText = "\(artist) - \(album)"

			let image = NSImage(contentsOf: URL(string: imageUrl)!)
			userNotification.contentImage = image

			NSUserNotificationCenter.default.deliver(userNotification)
		})
	}

	internal func playstateChanged(notification : Notification) {
		if let userInfo = notification.userInfo, let message = userInfo["message"] as? String {
			let opts = Utils.extractOptions(message: message)
			if let newState = opts["state"] {
				track?.setPlaystate(playstate: Playstate(rawValue: newState)!)
			}
		}
	}


	internal func configFetcherError(err: String) {
		print(err)
	}

	internal func configFetchedSuccessfully(groups: [PlayGroup], players: [PlayerDetails]) {
		DeviceStore.getInstance().setInitial(groups: groups, andPlayers: players)
		setupStatusBar()
	}

}

