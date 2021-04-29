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

import ProgressHUD

//-------------------------------------------------------------------------------------------------------------------------------------------------
class SettingsView: UITableViewController {

	@IBOutlet var viewHeader: UIView!
	@IBOutlet var imageUser: UIImageView!
	@IBOutlet var labelInitials: UILabel!
	@IBOutlet var labelName: UILabel!
	@IBOutlet var cellProfile: UITableViewCell!
	@IBOutlet var cellPassword: UITableViewCell!
	@IBOutlet var cellStatus: UITableViewCell!
	@IBOutlet var cellBlocked: UITableViewCell!
	@IBOutlet var cellArchive: UITableViewCell!
	@IBOutlet var cellCache: UITableViewCell!
	@IBOutlet var cellMedia: UITableViewCell!
	@IBOutlet var cellWallpapers: UITableViewCell!
	@IBOutlet var cellPrivacy: UITableViewCell!
	@IBOutlet var cellTerms: UITableViewCell!
	@IBOutlet var cellLogout: UITableViewCell!

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {

		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

		tabBarItem.image = UIImage(systemName: "gear")
		tabBarItem.title = "Settings"

		NotificationCenter.addObserver(target: self, selector: #selector(loadPerson), name: NOTIFICATION_USER_LOGGED_IN)
		NotificationCenter.addObserver(target: self, selector: #selector(actionCleanup), name: NOTIFICATION_USER_LOGGED_OUT)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	required init?(coder aDecoder: NSCoder) {

		super.init(coder: aDecoder)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Settings"

		navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)

		tableView.tableHeaderView = viewHeader
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidAppear(_ animated: Bool) {

		super.viewDidAppear(animated)

		if (AuthUser.userId() != "") {
			if (Persons.fullname() != "") {
				loadPerson()
			} else { Users.onboard(target: self) }
		}
	}

	// MARK: - Realm methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func loadPerson() {

		guard let person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId()) else { return }

		labelInitials.text = person.initials()
		MediaDownload.user(person.objectId, pictureAt: person.pictureAt) { image, error in
			if (error == nil) {
				self.imageUser.image = image?.square(to: 70)
				self.labelInitials.text = nil
			}
		}

		labelName.text = person.fullname
		cellStatus.textLabel?.text = person.status

		tableView.reloadData()
	}

	// MARK: - User actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionProfile() {

		let editProfileView = EditProfileView(isOnboard: false)
		let navController = NavigationController(rootViewController: editProfileView)
		navController.isModalInPresentation = true
		navController.modalPresentationStyle = .fullScreen
		present(navController, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionPassword() {

		let passwordView = PasswordView()
		let navController = NavigationController(rootViewController: passwordView)
		navController.isModalInPresentation = true
		navController.modalPresentationStyle = .fullScreen
		present(navController, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionStatus() {

		let statusView = StatusView()
		statusView.hidesBottomBarWhenPushed = true
		navigationController?.pushViewController(statusView, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionBlocked() {

		let blockedView = BlockedView()
		blockedView.hidesBottomBarWhenPushed = true
		navigationController?.pushViewController(blockedView, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionArchive() {

		let archivedView = ArchivedView()
		archivedView.hidesBottomBarWhenPushed = true
		navigationController?.pushViewController(archivedView, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionCache() {

		let cacheView = CacheView()
		cacheView.hidesBottomBarWhenPushed = true
		navigationController?.pushViewController(cacheView, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionMedia() {

		let mediaView = MediaView()
		mediaView.hidesBottomBarWhenPushed = true
		navigationController?.pushViewController(mediaView, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionWallpapers() {

		let wallpapersView = WallpapersView()
		let navController = NavigationController(rootViewController: wallpapersView)
		present(navController, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionPrivacy() {

		let privacyView = PrivacyView()
		privacyView.hidesBottomBarWhenPushed = true
		navigationController?.pushViewController(privacyView, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionTerms() {

		let termsView = TermsView()
		termsView.hidesBottomBarWhenPushed = true
		navigationController?.pushViewController(termsView, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionLogout() {

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		alert.addAction(UIAlertAction(title: "Log out", style: .destructive) { action in
			self.actionLogoutUser()
		})
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

		present(alert, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionLogoutUser() {

		ProgressHUD.show(nil, interaction: false)
		Users.prepareLogout()
		DispatchQueue.main.async(after: 1.0) {
			Users.performLogout()
			ProgressHUD.dismiss()
			self.tabBarController?.selectedIndex = App.DefaultTab
		}
	}

	// MARK: - Cleanup methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionCleanup() {

		imageUser.image = nil
		labelName.text = nil
	}

	// MARK: - Table view data source
	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func numberOfSections(in tableView: UITableView) -> Int {

		return 5
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		let emailLogin = (Persons.loginMethod() == LOGIN_EMAIL)

		if (section == 0) { return emailLogin ? 2 : 1	}
		if (section == 1) { return 1					}
		if (section == 2) { return 5					}
		if (section == 3) { return 2					}
		if (section == 4) { return 1					}

		return 0
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

		if (section == 1) { return "Status" }

		return nil
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if (indexPath.section == 0) && (indexPath.row == 0) { return cellProfile			}
		if (indexPath.section == 0) && (indexPath.row == 1) { return cellPassword			}
		if (indexPath.section == 1) && (indexPath.row == 0) { return cellStatus				}
		if (indexPath.section == 2) && (indexPath.row == 0) { return cellBlocked			}
		if (indexPath.section == 2) && (indexPath.row == 1) { return cellArchive			}
		if (indexPath.section == 2) && (indexPath.row == 2) { return cellCache				}
		if (indexPath.section == 2) && (indexPath.row == 3) { return cellMedia				}
		if (indexPath.section == 2) && (indexPath.row == 4) { return cellWallpapers			}
		if (indexPath.section == 3) && (indexPath.row == 0) { return cellPrivacy			}
		if (indexPath.section == 3) && (indexPath.row == 1) { return cellTerms				}
		if (indexPath.section == 4) && (indexPath.row == 0) { return cellLogout				}

		return UITableViewCell()
	}

	// MARK: - Table view delegate
	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		if (indexPath.section == 0) && (indexPath.row == 0) { actionProfile()			}
		if (indexPath.section == 0) && (indexPath.row == 1) { actionPassword()			}
		if (indexPath.section == 1) && (indexPath.row == 0) { actionStatus()			}
		if (indexPath.section == 2) && (indexPath.row == 0) { actionBlocked()			}
		if (indexPath.section == 2) && (indexPath.row == 1) { actionArchive()			}
		if (indexPath.section == 2) && (indexPath.row == 2) { actionCache()				}
		if (indexPath.section == 2) && (indexPath.row == 3) { actionMedia()				}
		if (indexPath.section == 2) && (indexPath.row == 4) { actionWallpapers()		}
		if (indexPath.section == 3) && (indexPath.row == 0) { actionPrivacy()			}
		if (indexPath.section == 3) && (indexPath.row == 1) { actionTerms()				}
		if (indexPath.section == 4) && (indexPath.row == 0) { actionLogout()			}
	}
}
