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
class RCAudioLoader: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func start(_ rcmessage: RCMessage, in tableView: UITableView) {

		if let path = Media.pathAudio(rcmessage.messageId) {
			showMedia(rcmessage, path: path)
		} else {
			loadMedia(rcmessage, in: tableView)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func manual(_ rcmessage: RCMessage, in tableView: UITableView) {

		Media.clearManualAudio(rcmessage.messageId)
		downloadMedia(rcmessage, in: tableView)
		tableView.reloadData()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func loadMedia(_ rcmessage: RCMessage, in tableView: UITableView) {

		let network = Persons.networkAudio()

		if (network == Network.Manual) || ((network == Network.WiFi) && (Connectivity.isReachableViaWiFi() == false)) {
			rcmessage.mediaStatus = MediaStatus.Manual
		} else {
			downloadMedia(rcmessage, in: tableView)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func downloadMedia(_ rcmessage: RCMessage, in tableView: UITableView) {

		rcmessage.mediaStatus = MediaStatus.Loading

		MediaDownload.audio(rcmessage.messageId) { path, error in
			if (error == nil) {
				Cryptor.decrypt(path: path)
				showMedia(rcmessage, path: path)
			} else {
				rcmessage.mediaStatus = MediaStatus.Manual
			}
			tableView.reloadData()
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private class func showMedia(_ rcmessage: RCMessage, path: String) {

		rcmessage.audioPath = path
		rcmessage.mediaStatus = MediaStatus.Succeed
	}
}
