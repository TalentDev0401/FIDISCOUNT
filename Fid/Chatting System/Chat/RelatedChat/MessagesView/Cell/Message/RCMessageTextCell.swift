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
class RCMessageTextCell: RCMessageCell {

	private var textView: UITextView!

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func bindData(_ messagesView: RCMessagesView, at indexPath: IndexPath) {

		super.bindData(messagesView, at: indexPath)

		let rcmessage = messagesView.rcmessageAt(indexPath)

		viewBubble.backgroundColor = rcmessage.incoming ? RCDefaults.textBubbleColorIncoming : RCDefaults.textBubbleColorOutgoing

		if (textView == nil) {
			textView = UITextView()
			textView.font = RCDefaults.textFont
			textView.isEditable = false
            
			
			textView.isScrollEnabled = false
			textView.backgroundColor = UIColor.clear
			textView.textContainer.lineFragmentPadding = 0
			textView.textContainerInset = RCDefaults.textInset
			viewBubble.addSubview(textView)
		}

        textView.delegate = self
		textView.textColor = rcmessage.incoming ? RCDefaults.textTextColorIncoming : RCDefaults.textTextColorOutgoing

		textView.text = rcmessage.text
        
        let textColor = rcmessage.incoming ? RCDefaults.textTextColorIncoming : RCDefaults.textTextColorOutgoing
        
        let splits = rcmessage.text.components(separatedBy: "shared by FID app\n")
        if splits.count != 0 {
            let urlStr = splits.last!
            textView.hyperLink(originalText: rcmessage.text, hyperLink: urlStr, urlString: urlStr, textColor: textColor)
        } else {
            textView.isSelectable = false
            textView.isUserInteractionEnabled = false
        }
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func layoutSubviews() {

		let size = RCMessageTextCell.size(messagesView, at: indexPath)

		super.layoutSubviews(size)

		textView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
	}

	// MARK: - Size methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func height(_ messagesView: RCMessagesView, at indexPath: IndexPath) -> CGFloat {

		let size = self.size(messagesView, at: indexPath)
		return size.height
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func size(_ messagesView: RCMessagesView, at indexPath: IndexPath) -> CGSize {

		let rcmessage = messagesView.rcmessageAt(indexPath)

		let widthTable = messagesView.tableView.frame.size.width

		let maxwidth = (0.6 * widthTable) - RCDefaults.textInsetLeft - RCDefaults.textInsetRight

		let rect = rcmessage.text.boundingRect(with: CGSize(width: maxwidth, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: RCDefaults.textFont], context: nil)

		let width = rect.size.width + RCDefaults.textInsetLeft + RCDefaults.textInsetRight
		let height = rect.size.height + RCDefaults.textInsetTop + RCDefaults.textInsetBottom

		return CGSize(width: CGFloat.maximum(width, RCDefaults.textBubbleWidthMin), height: CGFloat.maximum(height, RCDefaults.textBubbleHeightMin))
	}
}

extension RCMessageTextCell: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        
        UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        
        return false
    }
}

