//
// Copyright (c) 2020 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

//-------------------------------------------------------------------------------------------------------------------------------------------------
class Media: NSObject {

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func pathUser(_ name: String) -> String?	{ return path(dir: "user", name: name, ext: "jpg")	}
	class func pathPhoto(_ name: String) -> String?	{ return path(dir: "media", name: name, ext: "jpg")	}
	class func pathVideo(_ name: String) -> String?	{ return path(dir: "media", name: name, ext: "mp4")	}
	class func pathAudio(_ name: String) -> String?	{ return path(dir: "media", name: name, ext: "m4a")	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func path(dir: String, name: String, ext: String) -> String? {

		let file = "\(name).\(ext)"
		let path = Dir.document(dir, and: file)

		return File.exist(path: path) ? path : nil
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func pathPhoto(_ name: String) -> String	{ return path(dir: "media", name: name, ext: "jpg")	}
	class func pathVideo(_ name: String) -> String	{ return path(dir: "media", name: name, ext: "mp4")	}
	class func pathAudio(_ name: String) -> String	{ return path(dir: "media", name: name, ext: "m4a")	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func path(dir: String, name: String, ext: String) -> String {

		let file = "\(name).\(ext)"
		return Dir.document(dir, and: file)
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func clearManualPhoto(_ name: String) { clearManual(dir: "media", name: name, ext: "jpg") }
	class func clearManualVideo(_ name: String) { clearManual(dir: "media", name: name, ext: "mp4") }
	class func clearManualAudio(_ name: String) { clearManual(dir: "media", name: name, ext: "m4a") }
	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func clearManual(dir: String, name: String, ext: String) {

		let file = "\(name).\(ext)"

		let fileManual = file + ".manual"
		let pathManual = Dir.document(dir, and: fileManual)

		let fileLoading = file + ".loading"
		let pathLoading = Dir.document(dir, and: fileLoading)

		File.remove(path: pathManual)
		File.remove(path: pathLoading)
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func saveUser(_ name: String, data: Data)		{ save(data: data, dir: "user", name: name, ext: "jpg", manual: false, encrypt: true)	}
	class func savePhoto(_ name: String, data: Data)	{ save(data: data, dir: "media", name: name, ext: "jpg", manual: true, encrypt: true)	}
	class func saveVideo(_ name: String, data: Data)	{ save(data: data, dir: "media", name: name, ext: "mp4", manual: true, encrypt: false)	}
	class func saveAudio(_ name: String, data: Data)	{ save(data: data, dir: "media", name: name, ext: "m4a", manual: true, encrypt: false)	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func save(data: Data, dir: String, name: String, ext: String, manual: Bool, encrypt: Bool) {

		let file = "\(name).\(ext)"
		let path = Dir.document(dir, and: file)

		if (encrypt) {
			if let encrypted = Cryptor.encrypt(data: data) {
				encrypted.write(path: path, options: .atomic)
			}
		} else {
			data.write(path: path, options: .atomic)
		}

		if (manual) {
			let fileManual = file + ".manual"
			let pathManual = Dir.document(dir, and: fileManual)
			try? "manual".write(toFile: pathManual, atomically: false, encoding: .utf8)
		}
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func cleanupExpired() {

		if (AuthUser.userId() != "") {
			if (Persons.keepMedia() == KeepMedia.Week) {
				cleanupExpired(days: 7)
			}
			if (Persons.keepMedia() == KeepMedia.Month) {
				cleanupExpired(days: 30)
			}
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func cleanupExpired(days: Int) {

		var isDir: ObjCBool = false
		let extensions = ["jpg", "mp4", "m4a"]

		let past = Date().addingTimeInterval(TimeInterval(-days * 24 * 60 * 60))

		// Clear Documents files
		//-----------------------------------------------------------------------------------------------------------------------------------------
		if let enumerator = FileManager.default.enumerator(atPath: Dir.document()) {
			while let file = enumerator.nextObject() as? String {
				let path = Dir.document(file)
				FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
				if (isDir.boolValue == false) {
					let ext = (path as NSString).pathExtension
					if (extensions.contains(ext)) {
						let created = File.created(path: path)
						if (created.compare(past) == .orderedAscending) {
							File.remove(path: path)
						}
					}
				}
			}
		}

		// Clear Caches files
		//-----------------------------------------------------------------------------------------------------------------------------------------
		if let files = try? FileManager.default.contentsOfDirectory(atPath: Dir.cache()) {
			for file in files {
				let path = Dir.cache(file)
				FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
				if (isDir.boolValue == false) {
					let ext = (path as NSString).pathExtension
					if (ext == "mp4") {
						let created = File.created(path: path)
						if (created.compare(past) == .orderedAscending) {
							File.remove(path: path)
						}
					}
				}
			}
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func cleanupManual(logout: Bool) {

		var isDir: ObjCBool = false
		let extensions = logout ? ["jpg", "mp4", "m4a", "manual", "loading"] : ["jpg", "mp4", "m4a"]

		// Clear Documents files
		//-----------------------------------------------------------------------------------------------------------------------------------------
		if let enumerator = FileManager.default.enumerator(atPath: Dir.document()) {
			while let file = enumerator.nextObject() as? String {
				let path = Dir.document(file)
				FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
				if (isDir.boolValue == false) {
					let ext = (path as NSString).pathExtension
					if (extensions.contains(ext)) {
						File.remove(path: path)
					}
				}
			}
		}

		// Clear Caches files
		//-----------------------------------------------------------------------------------------------------------------------------------------
		if let files = try? FileManager.default.contentsOfDirectory(atPath: Dir.cache()) {
			for file in files {
				let path = Dir.cache(file)
				FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
				if (isDir.boolValue == false) {
					let ext = (path as NSString).pathExtension
					if (ext == "mp4") {
						File.remove(path: path)
					}
				}
			}
		}
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func total() -> Int64 {

		var isDir: ObjCBool = false
		let extensions = ["jpg", "mp4", "m4a"]

		var total: Int64 = 0

		// Count Documents files
		//-----------------------------------------------------------------------------------------------------------------------------------------
		if let enumerator = FileManager.default.enumerator(atPath: Dir.document()) {
			while let file = enumerator.nextObject() as? String {
				let path = Dir.document(file)
				FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
				if (isDir.boolValue == false) {
					let ext = (path as NSString).pathExtension
					if (extensions.contains(ext)) {
						total += File.size(path: path)
					}
				}
			}
		}

		// Count Caches files
		//-----------------------------------------------------------------------------------------------------------------------------------------
		if let files = try? FileManager.default.contentsOfDirectory(atPath: Dir.cache()) {
			for file in files {
				let path = Dir.cache(file)
				FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
				if (isDir.boolValue == false) {
					let ext = (path as NSString).pathExtension
					if (ext == "mp4") {
						total += File.size(path: path)
					}
				}
			}
		}

		return total
	}
}
