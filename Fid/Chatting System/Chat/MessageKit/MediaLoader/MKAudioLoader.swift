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

import MessageKit

//-------------------------------------------------------------------------------------------------------------------------------------------------
class MKAudioLoader: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func start(_ mkmessage: MKMessage, in messagesCollectionView: MessagesCollectionView) {

		if let path = Media.pathAudio(mkmessage.messageId) {
			showMedia(mkmessage, path: path)
		} else {
			loadMedia(mkmessage, in: messagesCollectionView)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func manual(_ mkmessage: MKMessage, in messagesCollectionView: MessagesCollectionView) {

		Media.clearManualAudio(mkmessage.messageId)
		downloadMedia(mkmessage, in: messagesCollectionView)
		messagesCollectionView.reloadData()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func loadMedia(_ mkmessage: MKMessage, in messagesCollectionView: MessagesCollectionView) {

		let network = Persons.networkAudio()

		if (network == Network.Manual) || ((network == Network.WiFi) && (Connectivity.isReachableViaWiFi() == false)) {
			mkmessage.mediaStatus = MediaStatus.Manual
		} else {
			downloadMedia(mkmessage, in: messagesCollectionView)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func downloadMedia(_ mkmessage: MKMessage, in messagesCollectionView: MessagesCollectionView) {

		mkmessage.mediaStatus = MediaStatus.Loading

		MediaDownload.audio(mkmessage.messageId) { path, error in
			if (error == nil) {
				Cryptor.decrypt(path: path)
				showMedia(mkmessage, path: path)
			} else {
				mkmessage.mediaStatus = MediaStatus.Manual
			}
			messagesCollectionView.reloadData()
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func showMedia(_ mkmessage: MKMessage, path: String) {

		mkmessage.audioItem?.url = URL(fileURLWithPath: path)
		mkmessage.mediaStatus = MediaStatus.Succeed
	}
}
