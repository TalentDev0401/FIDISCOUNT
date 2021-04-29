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
import ProgressHUD

//-------------------------------------------------------------------------------------------------------------------------------------------------
class Messages: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func send(chatId: String, text: String?, photo: UIImage?, video: URL?, audio: String?) {

		let message = Message()

		message.chatId = chatId

		message.userId = AuthUser.userId()
		message.userFullname = Persons.fullname()
		message.userInitials = Persons.initials()
		message.userPictureAt = Persons.pictureAt()

		if let text = text			{ sendMessageText(message: message, text: text)		}
		else if let photo = photo	{ sendMessagePhoto(message: message, photo: photo)	}
		else if let video = video	{ sendMessageVideo(message: message, video: video)	}
		else if let audio = audio	{ sendMessageAudio(message: message, audio: audio)	}
		else						{ sendMessageLoaction(message: message)				}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func forward(chatId: String, message source: Message) {

		let message = Message()

		message.chatId = chatId

		message.userId = AuthUser.userId()
		message.userFullname = Persons.fullname()
		message.userInitials = Persons.initials()
		message.userPictureAt = Persons.pictureAt()

		message.type = source.type
		message.text = source.text

		message.photoWidth = source.photoWidth
		message.photoHeight = source.photoHeight
		message.videoDuration = source.videoDuration
		message.audioDuration = source.audioDuration

		message.latitude = source.latitude
		message.longitude = source.longitude

		if (message.type == MESSAGE_TEXT)		{ createMessage(message: message)	}
		if (message.type == MESSAGE_EMOJI)		{ createMessage(message: message)	}
		if (message.type == MESSAGE_LOCATION)	{ createMessage(message: message)	}

		if (message.type == MESSAGE_PHOTO)		{ forwardMessagePhoto(message: message, source: source)	}
		if (message.type == MESSAGE_VIDEO)		{ forwardMessageVideo(message: message, source: source)	}
		if (message.type == MESSAGE_AUDIO)		{ forwardMessageAudio(message: message, source: source)	}
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func forwardMessagePhoto(message: Message, source: Message) {

		message.isMediaQueued = true

		if let pathSource = Media.pathPhoto(source.objectId) {
			let pathMessage: String = Media.pathPhoto(message.objectId)
			File.copy(src: pathSource, dest: pathMessage, overwrite: true)
			createMessage(message: message)
		} else {
			ProgressHUD.showError("Missing media file.")
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func forwardMessageVideo(message: Message, source: Message) {

		message.isMediaQueued = true

		if let pathSource = Media.pathVideo(source.objectId) {
			let pathMessage: String = Media.pathVideo(message.objectId)
			File.copy(src: pathSource, dest: pathMessage, overwrite: true)
			createMessage(message: message)
		} else {
			ProgressHUD.showError("Missing media file.")
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func forwardMessageAudio(message: Message, source: Message) {

		message.isMediaQueued = true

		if let pathSource = Media.pathAudio(source.objectId) {
			let pathMessage: String = Media.pathAudio(message.objectId)
			File.copy(src: pathSource, dest: pathMessage, overwrite: true)
			createMessage(message: message)
		} else {
			ProgressHUD.showError("Missing media file.")
		}
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func sendMessageText(message: Message, text: String) {

		message.type = Emoji.isEmoji(text: text) ? MESSAGE_EMOJI : MESSAGE_TEXT
		message.text = text

		createMessage(message: message)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func sendMessagePhoto(message: Message, photo: UIImage) {

		message.type = MESSAGE_PHOTO
		message.text = "Photo message"

		message.photoWidth = Int(photo.size.width)
		message.photoHeight = Int(photo.size.height)
		message.isMediaQueued = true

		if let data = photo.jpegData(compressionQuality: 0.6) {
			Media.savePhoto(message.objectId, data: data)
			createMessage(message: message)
		} else {
			ProgressHUD.showError("Photo data error.")
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func sendMessageVideo(message: Message, video: URL) {

		message.type = MESSAGE_VIDEO
		message.text = "Video message"

		message.videoDuration = Video.duration(path: video.path)
		message.isMediaQueued = true

		if let data = Data(path: video.path) {
			Media.saveVideo(message.objectId, data: data)
			createMessage(message: message)
		} else {
			ProgressHUD.showError("Video data error.")
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func sendMessageAudio(message: Message, audio: String) {

		message.type = MESSAGE_AUDIO
		message.text = "Audio message"

		message.audioDuration = Audio.duration(path: audio)
		message.isMediaQueued = true

		if let data = Data(path: audio) {
			Media.saveAudio(message.objectId, data: data)
			createMessage(message: message)
		} else {
			ProgressHUD.showError("Audio data error.")
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func sendMessageLoaction(message: Message) {

		message.type = MESSAGE_LOCATION
		message.text = "Location message"

		message.latitude = LocationManager.latitude()
		message.longitude = LocationManager.longitude()

		createMessage(message: message)
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func createMessage(message: Message) {

		let realm = try! Realm()
		try! realm.safeWrite {
			realm.add(message, update: .modified)
		}

		Audio.playMessageOutgoing()

		Details.updateAll(chatId: message.chatId, isDeleted: false)
		Details.updateAll(chatId: message.chatId, isArchived: false)

		PushNotification.send(message: message)
	}
}
