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
import AVFoundation

//-------------------------------------------------------------------------------------------------------------------------------------------------
class Video: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func thumbnail(path: String) -> UIImage {

		let asset = AVURLAsset(url: URL(fileURLWithPath: path), options: nil)
		let generator = AVAssetImageGenerator(asset: asset)
		generator.appliesPreferredTrackTransform = true

		var time: CMTime = asset.duration
		time.value = CMTimeValue(0)
		var actualTime = CMTimeMake(value: 0, timescale: 0)

		if let cgImage = try? generator.copyCGImage(at: time, actualTime: &actualTime) {
			return UIImage(cgImage: cgImage)
		}

		return UIImage()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func duration(path: String) -> Int {

		let asset = AVURLAsset(url: URL(fileURLWithPath: path), options: nil)
		return Int(round(CMTimeGetSeconds(asset.duration)))
	}
}
