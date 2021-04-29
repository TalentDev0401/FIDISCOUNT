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
class FireObserver: NSObject {

	private var query: Query!
	private var type: SyncObject.Type!

	private var listener: ListenerRegistration?

	//---------------------------------------------------------------------------------------------------------------------------------------------
	init(_ query: Query, to type: SyncObject.Type) {

		super.init()

		self.query = query
		self.type = type

		listener = query.addSnapshotListener { querySnapshot, error in
			if let snapshot = querySnapshot {
				DispatchQueue.main.async {
					let realm = try! Realm()
					try! realm.safeWrite {
						for documentChange in snapshot.documentChanges {
							let data = documentChange.document.data()
							self.updateRealm(realm, data)
						}
					}
				}
			}
		}
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func removeObserver() {

		listener?.remove()
		listener = nil
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func updateRealm(_ realm: Realm, _ values: [String: Any]) {

		var temp = values

		temp["neverSynced"] = false
		temp["syncRequired"] = false

		for property in type.encryptedProperties() {
			if let value = temp[property] as? String {
				if let decrypted = Cryptor.decrypt(text: value) {
					temp[property] = decrypted
				}
			}
		}

		realm.create(type, value: temp, update: .modified)
	}
}
