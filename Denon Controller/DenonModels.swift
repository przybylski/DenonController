//  Copyright (c) 2017 Bartosz Przybylski

struct PlayerDetails {
	var name : String
	var pid : Int
	var gid : Int?
	var ip : String
}

struct PlaygroupMember {
	var name : String
	var pid : Int
	var role : String
}

struct PlayGroup {
	var name : String
	var gid : Int
	var members : [PlaygroupMember]
}
