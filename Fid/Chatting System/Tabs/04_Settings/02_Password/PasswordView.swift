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
class PasswordView: UIViewController {

	@IBOutlet var tableView: UITableView!
	@IBOutlet var cellPassword0: UITableViewCell!
	@IBOutlet var cellPassword1: UITableViewCell!
	@IBOutlet var cellPassword2: UITableViewCell!
	@IBOutlet var fieldPassword0: UITextField!
	@IBOutlet var fieldPassword1: UITextField!
	@IBOutlet var fieldPassword2: UITextField!

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Change Password"

		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(actionDismiss))
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(actionDone))

		let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		tableView.addGestureRecognizer(gestureRecognizer)
		gestureRecognizer.cancelsTouchesInView = false
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidAppear(_ animated: Bool) {

		super.viewDidAppear(animated)

		fieldPassword0.becomeFirstResponder()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillDisappear(_ animated: Bool) {

		super.viewWillDisappear(animated)

		dismissKeyboard()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func dismissKeyboard() {

		view.endEditing(true)
	}

	// MARK: - Backend actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func checkPassword() {

		let password = fieldPassword0.text ?? ""

		ProgressHUD.show(nil, interaction: false)
		AuthUser.checkPassword(password: password) { error in
			if let error = error {
				ProgressHUD.showError(error.localizedDescription)
			} else {
				self.updatePassword()
			}
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updatePassword() {

		let password = fieldPassword1.text ?? ""

		AuthUser.updatePassword(password: password) { error in
			if let error = error {
				ProgressHUD.showError(error.localizedDescription)
			} else {
				ProgressHUD.showSuccess("Password changed.")
				self.dismiss(animated: true)
			}
		}
	}

	// MARK: - User actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionDismiss() {

		dismiss(animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionDone() {

		let password0 = fieldPassword0.text ?? ""
		let password1 = fieldPassword1.text ?? ""
		let password2 = fieldPassword2.text ?? ""

		if (password0.count == 0)	{ ProgressHUD.showError("Current Password must be set.");	return	}
		if (password1.count == 0)	{ ProgressHUD.showError("New Password must be set.");		return	}
		if (password1 != password2)	{ ProgressHUD.showError("New Passwords must be the same.");	return	}

		checkPassword()
	}
}

// MARK: - UITableViewDataSource
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension PasswordView: UITableViewDataSource {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return 2
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		if (section == 0) { return 1 }
		if (section == 1) { return 2 }

		return 0
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		if (indexPath.section == 0) && (indexPath.row == 0) { return cellPassword0	}
		if (indexPath.section == 1) && (indexPath.row == 0) { return cellPassword1	}
		if (indexPath.section == 1) && (indexPath.row == 1) { return cellPassword2	}

		return UITableViewCell()
	}
}

// MARK: - UITableViewDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension PasswordView: UITableViewDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)
	}
}

// MARK: - UITextFieldDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension PasswordView: UITextFieldDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {

		if (textField == fieldPassword0) { fieldPassword1.becomeFirstResponder()	}
		if (textField == fieldPassword1) { fieldPassword2.becomeFirstResponder()	}
		if (textField == fieldPassword2) { actionDone()								}

		return true
	}
}
