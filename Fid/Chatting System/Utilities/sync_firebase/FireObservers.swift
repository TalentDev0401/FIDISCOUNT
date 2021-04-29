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

import FirebaseFirestore
import RealmSwift

//-------------------------------------------------------------------------------------------------------------------------------------------------
class FireObservers: NSObject {

	private var observerPerson:		FireObserver?
	private var observerFriend:		FireObserver?
	private var observerBlocked:	FireObserver?
	private var observerBlocker:	FireObserver?
	private var observerSingle1:	FireObserver?
	private var observerSingle2:	FireObserver?
	private var observerMember:		FireObserver?

	private var tokenMembers:		NotificationToken?

	private var observerMembers:	[String: FireObserver] = [:]
	private var observerGroups:		[String: FireObserver] = [:]
	private var observerDetails:	[String: FireObserver] = [:]
	private var observerMessages:	[String: FireObserver] = [:]

	private var members	= realm.objects(Member.self).filter(falsepredicate)

	//---------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: FireObservers = {
		let instance = FireObservers()
		return instance
	} ()

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override init() {

		super.init()

		NotificationCenter.addObserver(target: self, selector: #selector(initObservers), name: NOTIFICATION_APP_STARTED)
		NotificationCenter.addObserver(target: self, selector: #selector(initObservers), name: NOTIFICATION_USER_LOGGED_IN)
		NotificationCenter.addObserver(target: self, selector: #selector(stopObservers), name: NOTIFICATION_USER_LOGGED_OUT)
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc private func initObservers() {

        print("initObservers *********************************")
		if (AuthUser.userId() != "") {
			createObserverPerson()
			createObserverFriend()
			createObserverBlocked()
			createObserverBlocker()
			createObserverSingle1()
			createObserverSingle2()
			createObserverMember()
			createMemberDependencies()
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc private func stopObservers() {

		removeObserverPerson()
		removeObserverFriend()
		removeObserverBlocked()
		removeObserverBlocker()
		removeObserverSingle1()
		removeObserverSingle2()
		removeObserverMember()
		removeMemberDependencies()
	}

	// MARK: - Person
	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func createObserverPerson() {

		if (observerPerson == nil) {
			let query = Firestore.firestore().collection("Person").whereField("updatedAt", isGreaterThan: Person.lastUpdatedAt())
			observerPerson = FireObserver(query, to: Person.self)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func removeObserverPerson() {

		observerPerson?.removeObserver()
		observerPerson = nil
	}

	// MARK: - Friend
	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func createObserverFriend() {

		if (observerFriend == nil) {
			let query = Firestore.firestore().collection("Friend").whereField("userId", isEqualTo: AuthUser.userId())
			observerFriend = FireObserver(query, to: Friend.self)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func removeObserverFriend() {

		observerFriend?.removeObserver()
		observerFriend = nil
	}

	// MARK: - Blocked
	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func createObserverBlocked() {

		if (observerBlocked == nil) {
			let query = Firestore.firestore().collection("Blocked").whereField("blockedId", isEqualTo: AuthUser.userId())
			observerBlocked = FireObserver(query, to: Blocked.self)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func removeObserverBlocked() {

		observerBlocked?.removeObserver()
		observerBlocked = nil
	}

	// MARK: - Blocker
	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func createObserverBlocker() {

		if (observerBlocker == nil) {
			let query = Firestore.firestore().collection("Blocked").whereField("blockerId", isEqualTo: AuthUser.userId())
			observerBlocker = FireObserver(query, to: Blocked.self)
		}
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func removeObserverBlocker() {

		observerBlocker?.removeObserver()
		observerBlocker = nil
	}

	// MARK: - Single1
	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func createObserverSingle1() {

		if (observerSingle1 == nil) {
			let query = Firestore.firestore().collection("Single").whereField("userId1", isEqualTo: AuthUser.userId())
			observerSingle1 = FireObserver(query, to: Single.self)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func removeObserverSingle1() {

		observerSingle1?.removeObserver()
		observerSingle1 = nil
	}

	// MARK: - Single2
	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func createObserverSingle2() {

		if (observerSingle2 == nil) {
			let query = Firestore.firestore().collection("Single").whereField("userId2", isEqualTo: AuthUser.userId())
			observerSingle2 = FireObserver(query, to: Single.self)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func removeObserverSingle2() {

		observerSingle2?.removeObserver()
		observerSingle2 = nil
	}

	// MARK: - Member
	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func createObserverMember() {

		if (observerMember == nil) {
			let query = Firestore.firestore().collection("Member").whereField("userId", isEqualTo: AuthUser.userId())
			observerMember = FireObserver(query, to: Member.self)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func removeObserverMember() {

		observerMember?.removeObserver()
		observerMember = nil
	}

	// MARK: - Member Dependencies
	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func createMemberDependencies() {

		if (tokenMembers != nil) { return }

		let predicate = NSPredicate(format: "userId == %@", AuthUser.userId())
		members = realm.objects(Member.self).filter(predicate)

		members.safeObserve({ changes in
			switch changes {
				case .initial:
					for member in self.members {
						if (member.isActive) {
							self.createMemberDependencies(member.chatId)
						}
					}
				case .update(let results, _, let insert, let modify):
					for index in insert + modify {
						let member = results[index]
						if (member.isActive) {
							self.createMemberDependencies(member.chatId)
						} else {
							self.removeMemberDependencies(member.chatId)
						}
					}
				default: break
			}
		}, completion: { token in
			self.tokenMembers = token
		})
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func removeMemberDependencies() {

		tokenMembers?.invalidate()
		tokenMembers = nil

		members	= realm.objects(Member.self).filter(falsepredicate)

		for chatId in observerMembers.keys	{ removeObserverMember(chatId)	}
		for chatId in observerGroups.keys	{ removeObserverGroup(chatId)	}
		for chatId in observerDetails.keys	{ removeObserverDetail(chatId)	}
		for chatId in observerMessages.keys	{ removeObserverMessage(chatId)	}
	}

	// MARK: - Member Dependencies by chatId
	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func createMemberDependencies(_ chatId: String) {

		createObserverMember(chatId)
		createObserverGroup(chatId)
		createObserverDetail(chatId)
		createObserverMessage(chatId)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func removeMemberDependencies(_ chatId: String) {

		removeObserverMember(chatId)
		removeObserverGroup(chatId)
		removeObserverDetail(chatId)
		removeObserverMessage(chatId)
	}

	// MARK: - Member by chatId
	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func createObserverMember(_ chatId: String) {

		if (observerMembers[chatId] == nil) {
			let query = Firestore.firestore().collection("Member").whereField("chatId", isEqualTo: chatId)
			observerMembers[chatId] = FireObserver(query, to: Member.self)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func removeObserverMember(_ chatId: String) {

		if (observerMembers[chatId] != nil) {
			observerMembers[chatId]?.removeObserver()
			observerMembers.removeValue(forKey: chatId)
		}
	}

	// MARK: - Group by chatId
	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func createObserverGroup(_ chatId: String) {

		if (observerGroups[chatId] == nil) {
			let query = Firestore.firestore().collection("Group").whereField("chatId", isEqualTo: chatId)
			observerGroups[chatId] = FireObserver(query, to: Group.self)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func removeObserverGroup(_ chatId: String) {

		if (observerGroups[chatId] != nil) {
			observerGroups[chatId]?.removeObserver()
			observerGroups.removeValue(forKey: chatId)
		}
	}

	// MARK: - Detail by chatId
	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func createObserverDetail(_ chatId: String) {

		if (observerDetails[chatId] == nil) {
			let query = Firestore.firestore().collection("Detail").whereField("chatId", isEqualTo: chatId)
			observerDetails[chatId] = FireObserver(query, to: Detail.self)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func removeObserverDetail(_ chatId: String) {

		if (observerDetails[chatId] != nil) {
			observerDetails[chatId]?.removeObserver()
			observerDetails.removeValue(forKey: chatId)
		}
	}

	// MARK: - Message by chatId
	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func createObserverMessage(_ chatId: String) {

		if (observerMessages[chatId] == nil) {
			let query = Firestore.firestore().collection("Message").whereField("chatId", isEqualTo: chatId)
				.whereField("updatedAt", isGreaterThan: Message.lastUpdatedAt(chatId))
			observerMessages[chatId] = FireObserver(query, to: Message.self)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func removeObserverMessage(_ chatId: String) {

		if (observerMessages[chatId] != nil) {
			observerMessages[chatId]?.removeObserver()
			observerMessages.removeValue(forKey: chatId)
		}
	}
}
