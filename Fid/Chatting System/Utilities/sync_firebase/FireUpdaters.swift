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

import Foundation

//-------------------------------------------------------------------------------------------------------------------------------------------------
class FireUpdaters: NSObject {

	private var updaterPerson:	FireUpdater?
	private var updaterFriend:	FireUpdater?
	private var updaterBlocked:	FireUpdater?
	private var updaterSingle:	FireUpdater?
	private var updaterMember:	FireUpdater?

	private var updaterGroup:	FireUpdater?
	private var updaterDetail:	FireUpdater?
	private var updaterMessage:	FireUpdater?

	private var timer: Timer?

	//---------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: FireUpdaters = {
		let instance = FireUpdaters()
		return instance
	} ()

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override init() {

		super.init()

		NotificationCenter.addObserver(target: self, selector: #selector(initTimer), name: NOTIFICATION_USER_LOGGED_IN)
		NotificationCenter.addObserver(target: self, selector: #selector(stopTimer), name: NOTIFICATION_USER_LOGGED_OUT)

		updaterPerson	= FireUpdater(name: "Person", type: Person.self)
		updaterFriend	= FireUpdater(name: "Friend", type: Friend.self)
		updaterBlocked	= FireUpdater(name: "Blocked", type: Blocked.self)
		updaterSingle	= FireUpdater(name: "Single", type: Single.self)
		updaterMember	= FireUpdater(name: "Member", type: Member.self)

		updaterGroup	= FireUpdater(name: "Group", type: Group.self)
		updaterDetail	= FireUpdater(name: "Detail", type: Detail.self)
		updaterMessage	= FireUpdater(name: "Message", type: Message.self)

		if (AuthUser.userId() != "") {
			initTimer()
		}
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc private func initTimer() {

		timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { _ in
			if (Connectivity.isReachable()) {
				self.updateNext()
			}
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc private func stopTimer() {

		timer?.invalidate()
		timer = nil
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func updateNext() {

		updaterPerson?.updateNext()
		updaterFriend?.updateNext()
		updaterBlocked?.updateNext()
		updaterSingle?.updateNext()
		updaterMember?.updateNext()

		updaterGroup?.updateNext()
		updaterDetail?.updateNext()
		updaterMessage?.updateNext()
	}
}
