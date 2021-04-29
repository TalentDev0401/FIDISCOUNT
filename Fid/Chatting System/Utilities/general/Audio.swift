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

import AVFoundation

//-------------------------------------------------------------------------------------------------------------------------------------------------
class Audio: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func duration(path: String) -> Int {

		let asset = AVURLAsset(url: URL(fileURLWithPath: path), options: nil)
		return Int(round(CMTimeGetSeconds(asset.duration)))
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func playMessageIncoming() {

		let path = Dir.application("rcmessage_incoming.aiff")
		RCAudioPlayer.shared.playSound(path)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func playMessageOutgoing() {

		let path = Dir.application("rcmessage_outgoing.aiff")
		RCAudioPlayer.shared.playSound(path)
	}
}
