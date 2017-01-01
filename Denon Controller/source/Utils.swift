//  Copyright (c) 2017 Bartosz Przybylski

import Foundation

class Utils {

	static func extractOptions(message: String) -> [String : String] {
		let optionsExtractor = try? NSRegularExpression(pattern: "^([a-zA-Z0-9]+)=([a-zA-Z0-9]+)+$", options: [.caseInsensitive, .anchorsMatchLines])
		let options = message
		var optionsDictionary = [String: String]()

		for (_, opt) in options.components(separatedBy: "&").enumerated() {
			optionsExtractor?.enumerateMatches(in: opt, options: [], range: NSRange(location: 0, length:opt.characters.count), using: { (resultOptional, flags, stop) in
				if let result = resultOptional, result.numberOfRanges == 3 {
					let key = (opt as NSString).substring(with: result.rangeAt(1)).lowercased()
					let value = (opt as NSString).substring(with: result.rangeAt(2))
					optionsDictionary[key] = value
				}
			})
		}

		return optionsDictionary
	}

}
