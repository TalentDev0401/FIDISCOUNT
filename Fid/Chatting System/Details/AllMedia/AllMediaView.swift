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
class AllMediaView: UIViewController {

	@IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var backImg: UIImageView!

	private var chatId = ""
	private var messages_media: [Message] = []

	//---------------------------------------------------------------------------------------------------------------------------------------------
	init(chatId: String) {

		super.init(nibName: nil, bundle: nil)

		self.chatId = chatId
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder aDecoder: NSCoder) {

		super.init(coder: aDecoder)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "All Media"
        
        let back = UIImage(named: "back")
        backImg.image = back?.withRenderingMode(.alwaysTemplate)
        backImg.tintColor = UIColor(hexString: "#27bdb1")

		collectionView.register(UINib(nibName: "AllMediaCell", bundle: nil), forCellWithReuseIdentifier: "AllMediaCell")

		loadMedia()
	}
    
    @IBAction func goback(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

	// MARK: - Load methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func loadMedia() {

		let predicate = NSPredicate(format: "chatId == %@ AND isDeleted == NO", chatId)
		let messages = realm.objects(Message.self).filter(predicate).sorted(byKeyPath: "createdAt")

		for message in messages {
			if (message.type == MESSAGE_PHOTO) {
				if (Media.pathPhoto(message.objectId) != nil) {
					messages_media.append(message)
				}
			}
			if (message.type == MESSAGE_VIDEO) {
				if (Media.pathVideo(message.objectId) != nil) {
					messages_media.append(message)
				}
			}
		}

		collectionView.reloadData()
	}

	// MARK: - User actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func presentPicture(message: Message) {

		if (Media.pathPhoto(message.objectId) != nil) {
			let pictureView = PictureView(chatId: chatId, messageId: message.objectId)
			present(pictureView, animated: true)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func presentVideo(message: Message) {

		if let path = Media.pathVideo(message.objectId) {
			let videoView = VideoView(path: path)
			present(videoView, animated: true)
		}
	}
}

// MARK: - UICollectionViewDataSource
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension AllMediaView: UICollectionViewDataSource {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in collectionView: UICollectionView) -> Int {

		return 1
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

		return messages_media.count
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AllMediaCell", for: indexPath) as! AllMediaCell

		let message = messages_media[indexPath.item]
		cell.bindData(message: message)

		return cell
	}
}

// MARK: - UICollectionViewDelegateFlowLayout
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension AllMediaView: UICollectionViewDelegateFlowLayout {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

		let screenWidth = UIScreen.main.bounds.size.width
		return CGSize(width: screenWidth/2, height: screenWidth/2)
	}
}

// MARK: - UICollectionViewDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension AllMediaView: UICollectionViewDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

		collectionView.deselectItem(at: indexPath, animated: true)

		let message = messages_media[indexPath.item]

		if (message.type == MESSAGE_PHOTO) {
			presentPicture(message: message)
		}
		if (message.type == MESSAGE_VIDEO) {
			presentVideo(message: message)
		}
	}
}
