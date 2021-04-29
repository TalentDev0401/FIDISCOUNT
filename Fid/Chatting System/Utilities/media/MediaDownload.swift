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

import UIKit

//-------------------------------------------------------------------------------------------------------------------------------------------------
class MediaDownload: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func user(_ name: String, pictureAt: Int, completion: @escaping (UIImage?, Error?) -> Void) {

		if (pictureAt != 0) {
			start(dir: "user", name: name, ext: "jpg", manual: false) { path, error in
				if (error == nil) {
					completion(UIImage(path: path), nil)
				} else {
					completion(nil, error)
				}
			}
		} else {
			completion(nil, NSError("Missing picture.", 100))
		}
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func photo(_ name: String, completion: @escaping (String, Error?) -> Void) {

		start(dir: "media", name: name, ext: "jpg", manual: true, completion: completion)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func video(_ name: String, completion: @escaping (String, Error?) -> Void) {

		start(dir: "media", name: name, ext: "mp4", manual: true, completion: completion)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func audio(_ name: String, completion: @escaping (String, Error?) -> Void) {

		start(dir: "media", name: name, ext: "m4a", manual: true, completion: completion)
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func start(dir: String, name: String, ext: String, manual: Bool, completion: @escaping (String, Error?) -> Void) {

		let file = "\(name).\(ext)"
		let path = Dir.document(dir, and: file)

		let fileManual = file + ".manual"
		let pathManual = Dir.document(dir, and: fileManual)

		let fileLoading = file + ".loading"
		let pathLoading = Dir.document(dir, and: fileLoading)

		// Check if file is already downloaded
		//-----------------------------------------------------------------------------------------------------------------------------------------
		if (File.exist(path: path)) {
			completion(path, nil)
			return
		}

		// Check if manual download is required
		//-----------------------------------------------------------------------------------------------------------------------------------------
		if (manual) {
			if (File.exist(path: pathManual)) {
				completion("", NSError("Manual download required.", 101))
				return
			}
			try? "manual".write(toFile: pathManual, atomically: false, encoding: .utf8)
		}

		// Check if file is currently downloading
		//-----------------------------------------------------------------------------------------------------------------------------------------
		let time = Int(Date().timeIntervalSince1970)

		if (File.exist(path: pathLoading)) {
			if let temp = try? String(contentsOfFile: pathLoading, encoding: .utf8) {
				if let check = Int(temp) {
					if (time - check < 60) {
						completion("", NSError("Already downloading.", 102))
						return
					}
				}
			}
		}
		try? "\(time)".write(toFile: pathLoading, atomically: false, encoding: .utf8)

		// Download the file
		//-----------------------------------------------------------------------------------------------------------------------------------------
		FireStorage.download(dir: dir, name: name, ext: ext) { path, error in
			File.remove(path: pathLoading)
			DispatchQueue.main.async {
				completion(path, error)
			}
		}
	}
}
