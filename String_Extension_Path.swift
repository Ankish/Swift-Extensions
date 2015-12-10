extension String {
	
	var pathSeparator: UnicodeScalar {
		return UnicodeScalar(47)
	}
	
	var extensionSeparator: UnicodeScalar {
		return UnicodeScalar(46)
	}
	
	private var beginsWithSeparator: Bool {
		let unis = self.characters
		guard unis.count > 0 else {
			return false
		}
		return unis[unis.startIndex] == Character(pathSeparator)
	}
	
	private var endsWithSeparator: Bool {
		let unis = self.characters
		guard unis.count > 0 else {
			return false
		}
		return unis[unis.endIndex.predecessor()] == Character(pathSeparator)
	}
	
	private func pathComponents(addFirstLast: Bool) -> [String] {
		var r = [String]()
		let unis = self.characters
		guard unis.count > 0 else {
			return r
		}
		
		if addFirstLast && self.beginsWithSeparator {
			r.append(String(pathSeparator))
		}
		
		r.appendContentsOf(self.characters.split(Character(pathSeparator)).map { String($0) })
		
		if addFirstLast && self.endsWithSeparator {
			r.append(String(pathSeparator))
		}
		return r
	}
	
	var pathComponents: [String] {
		return self.pathComponents(true)
	}
	
	var lastPathComponent: String {
		let last = self.pathComponents(false).last ?? ""
		if last.isEmpty && self.characters.first == Character(pathSeparator) {
			return String(pathSeparator)
		}
		return last
	}
	
	var stringByDeletingLastPathComponent: String {
		var comps = self.pathComponents(false)
		guard comps.count > 1 else {
			if self.beginsWithSeparator {
				return String(pathSeparator)
			}
			return ""
		}
		comps.removeLast()
		let joined = comps.joinWithSeparator(String(pathSeparator))
		if self.beginsWithSeparator {
			return String(pathSeparator) + joined
		}
		return joined
	}
	
	var stringByDeletingPathExtension: String {
		let unis = self.characters
		let startIndex = unis.startIndex
		var endIndex = unis.endIndex
		while endIndex != startIndex {
			if unis[endIndex.predecessor()] != Character(pathSeparator) {
				break
			}
			endIndex = endIndex.predecessor()
		}
		let noTrailsIndex = endIndex
		while endIndex != startIndex {
			endIndex = endIndex.predecessor()
			if unis[endIndex] == Character(extensionSeparator) {
				break
			}
		}
		guard endIndex != startIndex else {
			if noTrailsIndex == startIndex {
				return self
			}
			return self.substringToIndex(noTrailsIndex)
		}
		return self.substringToIndex(endIndex)
	}
	
	var pathExtension: String {
		let unis = self.characters
		let startIndex = unis.startIndex
		var endIndex = unis.endIndex
		while endIndex != startIndex {
			if unis[endIndex.predecessor()] != Character(pathSeparator) {
				break
			}
			endIndex = endIndex.predecessor()
		}
		let noTrailsIndex = endIndex
		while endIndex != startIndex {
			endIndex = endIndex.predecessor()
			if unis[endIndex] == Character(extensionSeparator) {
				break
			}
		}
		guard endIndex != startIndex else {
			return ""
		}
		return self.substringWithRange(Range(start:endIndex.successor(), end:noTrailsIndex))
	}

	var stringByResolvingSymlinksInPath: String {
		let absolute = self.beginsWithSeparator
		let components = self.pathComponents(false)
		var s = absolute ? "/" : ""
		for component in components {
			if component == "." {
				s.appendContentsOf(".")
			} else if component == ".." {
				s.appendContentsOf("..")
			} else {
				let file = File(s + "/" + component)
				s = file.realPath()
			}
		}
		let ary = s.pathComponents(false) // get rid of slash runs
		return absolute ? "/" + ary.joinWithSeparator(String(pathSeparator)) : ary.joinWithSeparator(String(pathSeparator))
	}
