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

import RealmSwift

//-------------------------------------------------------------------------------------------------------------------------------------------------
class MediaUploader: NSObject {

	private var uploading = false

	private var messages = realm.objects(Message.self).filter(falsepredicate)

	private var timer: Timer?

	//---------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: MediaUploader = {
		let instance = MediaUploader()
		return instance
	} ()

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override init() {

		super.init()

		NotificationCenter.addObserver(target: self, selector: #selector(initTimer), name: NOTIFICATION_USER_LOGGED_IN)
		NotificationCenter.addObserver(target: self, selector: #selector(stopTimer), name: NOTIFICATION_USER_LOGGED_OUT)

		if (AuthUser.userId() != "") {
			initTimer()
		}
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc private func initTimer() {

		let predicate = NSPredicate(format: "userId == %@ AND isMediaQueued == YES AND isMediaFailed == NO", AuthUser.userId())
		messages = realm.objects(Message.self).filter(predicate).sorted(byKeyPath: "updatedAt")

		timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { _ in
			if (Connectivity.isReachable()) {
				self.uploadNext()
			}
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc private func stopTimer() {

		messages = realm.objects(Message.self).filter(falsepredicate)

		timer?.invalidate()
		timer = nil
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func uploadNext() {

		if (uploading) { return }

		if let message = messages.first {
			upload(message: message) { error in
				if (error == nil) {
					message.update(isMediaQueued: false)
				} else {
					message.update(isMediaFailed: true)
				}
				self.uploading = false
			}
		}
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func upload(message: Message, completion: @escaping (_ error: Error?) -> Void) {

		uploading = true

		if (message.type == MESSAGE_PHOTO) { uploadPhoto(message: message, completion: completion) }
		if (message.type == MESSAGE_VIDEO) { uploadVideo(message: message, completion: completion) }
		if (message.type == MESSAGE_AUDIO) { uploadAudio(message: message, completion: completion) }
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func uploadPhoto(message: Message, completion: @escaping (_ error: Error?) -> Void) {

		if let path = Media.pathPhoto(message.objectId) {
			if let data = Data(path: path) {
				MediaUpload.photo(message.objectId, data: data) { error in
					completion(error)
				}
			} else { completion(NSError("Media file error.", 102)) }
		} else { completion(NSError("Missing media file.", 103)) }
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func uploadVideo(message: Message, completion: @escaping (_ error: Error?) -> Void) {

		if let path = Media.pathVideo(message.objectId) {
			if let data = Data(path: path) {
				if let encrypted = Cryptor.encrypt(data: data) {
					MediaUpload.video(message.objectId, data: encrypted) { error in
						completion(error)
					}
				} else { completion(NSError("Media encryption error.", 101)) }
			} else { completion(NSError("Media file error.", 102)) }
		} else { completion(NSError("Missing media file.", 103)) }
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func uploadAudio(message: Message, completion: @escaping (_ error: Error?) -> Void) {

		if let path = Media.pathAudio(message.objectId) {
			if let data = Data(path: path) {
				if let encrypted = Cryptor.encrypt(data: data) {
					MediaUpload.audio(message.objectId, data: encrypted) { error in
						completion(error)
					}
				} else { completion(NSError("Media encryption error.", 101)) }
			} else { completion(NSError("Media file error.", 102)) }
		} else { completion(NSError("Missing media file.", 103)) }
	}
}
