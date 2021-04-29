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
class FireUpdater: NSObject {

	private var collection: String = ""

	private var updating = false

	private var objects: Results<SyncObject>?

	//---------------------------------------------------------------------------------------------------------------------------------------------
	init(name: String, type: SyncObject.Type) {

		super.init()

		collection = name

		let predicate = NSPredicate(format: "syncRequired == YES")
		objects = realm.objects(type).filter(predicate).sorted(byKeyPath: "updatedAt")
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateNext() {

		if (updating) { return }

		if let object = objects?.first {
			update(object)
		}
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func update(_ object: SyncObject) {

		updating = true

		let values = populate(object)

		if (object.neverSynced) {
			Firestore.firestore().collection(collection).document(object.objectId).setData(values) { error in
				if (error == nil) {
					object.updateSynced()
				}
				self.updating = false
			}
		} else {
			Firestore.firestore().collection(collection).document(object.objectId).updateData(values) { error in
				if (error == nil) {
					object.updateSynced()
				}
				self.updating = false
			}
		}
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	private func populate(_ object: SyncObject) -> [String: Any] {

		var values: [String: Any] = [:]

		for property in object.objectSchema.properties {
			let name = property.name
			if (name != "neverSynced") && (name != "syncRequired") {
				switch property.type {
					case .int:		if let value = object[name] as? Int		{ values[name] = value }
					case .bool:		if let value = object[name] as? Bool	{ values[name] = value }
					case .float:	if let value = object[name] as? Float	{ values[name] = value }
					case .double:	if let value = object[name] as? Double	{ values[name] = value }
					case .string:	if let value = object[name] as? String	{ values[name] = value }
					case .date:		if let value = object[name] as? Date	{ values[name] = value }
					default:		print("Property type \(property.type.rawValue) is not populated.")
				}
			}
		}

		for property in type(of: object).encryptedProperties() {
			if let value = object[property] as? String {
				if let encrypted = Cryptor.encrypt(text: value) {
					values[property] = encrypted
				}
			}
		}

		return values
	}
}
