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
class RCMessageLocationCell: RCMessageCell {

	private var imageViewThumb: UIImageView!
	private var activityIndicator: UIActivityIndicatorView!

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func bindData(_ messagesView: RCMessagesView, at indexPath: IndexPath) {

		super.bindData(messagesView, at: indexPath)

		let rcmessage = messagesView.rcmessageAt(indexPath)

		viewBubble.backgroundColor = rcmessage.incoming ? RCDefaults.locationBubbleColorIncoming : RCDefaults.locationBubbleColorOutgoing

		if (imageViewThumb == nil) {
			imageViewThumb = UIImageView()
			imageViewThumb.layer.masksToBounds = true
			imageViewThumb.layer.cornerRadius = RCDefaults.bubbleRadius
			viewBubble.addSubview(imageViewThumb)
		}

		if (activityIndicator == nil) {
			activityIndicator = UIActivityIndicatorView(style: .large)
			viewBubble.addSubview(activityIndicator)
		}

		if (rcmessage.mediaStatus == MediaStatus.Loading) {
			imageViewThumb.image = nil
			activityIndicator.startAnimating()
		}

		if (rcmessage.mediaStatus == MediaStatus.Succeed) {
			imageViewThumb.image = rcmessage.locationThumbnail
			activityIndicator.stopAnimating()
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func layoutSubviews() {

		let size = RCMessageLocationCell.size(messagesView, at: indexPath)

		super.layoutSubviews(size)

		imageViewThumb.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)

		let widthActivity = activityIndicator.frame.size.width
		let heightActivity = activityIndicator.frame.size.height
		let xActivity = (size.width - widthActivity) / 2
		let yActivity = (size.height - heightActivity) / 2
		activityIndicator.frame = CGRect(x: xActivity, y: yActivity, width: widthActivity, height: heightActivity)
	}

	// MARK: - Size methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func height(_ messagesView: RCMessagesView, at indexPath: IndexPath) -> CGFloat {

		let size = self.size(messagesView, at: indexPath)
		return size.height
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func size(_ messagesView: RCMessagesView, at indexPath: IndexPath) -> CGSize {

		return CGSize(width: RCDefaults.locationBubbleWidth, height: RCDefaults.locationBubbleHeight)
	}
}
