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
class MediaView: UIViewController {

	@IBOutlet var tableView: UITableView!
	@IBOutlet var cellPhoto: UITableViewCell!
	@IBOutlet var cellVideo: UITableViewCell!
	@IBOutlet var cellAudio: UITableViewCell!

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Media Settings"

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)

		updateCell(selectedNetwork: Persons.networkPhoto(), cell: cellPhoto)
		updateCell(selectedNetwork: Persons.networkVideo(), cell: cellVideo)
		updateCell(selectedNetwork: Persons.networkAudio(), cell: cellAudio)
	}

	// MARK: - Helper methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateCell(selectedNetwork: Int, cell: UITableViewCell) {

		if (selectedNetwork == Network.Manual)	{ cell.detailTextLabel?.text = "Manual"				}
		if (selectedNetwork == Network.WiFi)	{ cell.detailTextLabel?.text = "Wi-Fi"				}
		if (selectedNetwork == Network.All)		{ cell.detailTextLabel?.text = "Wi-Fi + Cellular"	}
	}

	// MARK: - User actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionNetwork(mediaType: Int) {

		let networkView = NetworkView(mediaType: mediaType)
		navigationController?.pushViewController(networkView, animated: true)
	}
}

// MARK: - UITableViewDataSource
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension MediaView: UITableViewDataSource {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return 1
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return 3
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if (indexPath.section == 0) && (indexPath.row == 0) { return cellPhoto }
		if (indexPath.section == 0) && (indexPath.row == 1) { return cellVideo }
		if (indexPath.section == 0) && (indexPath.row == 2) { return cellAudio }

		return UITableViewCell()
	}
}

// MARK: - UITableViewDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension MediaView: UITableViewDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		if (indexPath.section == 0) && (indexPath.row == 0) { actionNetwork(mediaType: MediaType.Photo)	}
		if (indexPath.section == 0) && (indexPath.row == 1) { actionNetwork(mediaType: MediaType.Video)	}
		if (indexPath.section == 0) && (indexPath.row == 2) { actionNetwork(mediaType: MediaType.Audio)	}
	}
}
