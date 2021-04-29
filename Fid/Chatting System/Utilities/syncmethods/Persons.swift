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

import RealmSwift

//-------------------------------------------------------------------------------------------------------------------------------------------------
class Persons: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func create(_ objectId: String, email: String) {

		let realm = try! Realm()
		try! realm.safeWrite {
			let person = Person()
			person.objectId = objectId
			person.email = email
			person.loginMethod = LOGIN_EMAIL
			realm.add(person, update: .modified)
		}
	}
    
    class func create(_ objectId: String, email: String, firstname: String, lastname: String, img: Bool) {
        
        let country = "Israel"
        let location = "Moscow"
        let phone = "123456789"
        
        let realm = try! Realm()
        try! realm.safeWrite {
            let person = Person()
            person.objectId = objectId
            person.email = email
            person.loginMethod = LOGIN_EMAIL
            person.firstname = firstname
            person.lastname    = lastname
            person.fullname    = "\(firstname) \(lastname)"
            person.country = country
            person.location    = location
            person.phone = phone
            person.syncRequired = true
            person.updatedAt = Date().timestamp()
            
            if img {
                person.update(pictureAt: Date().timestamp())
            }
                        
            realm.add(person, update: .modified)
        }
    }

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func fullname() -> String {

		let person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId())
		return person?.fullname ?? ""
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func initials() -> String {

		let person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId())
		return person?.initials() ?? ""
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func pictureAt() -> Int {

		let person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId())
		return person?.pictureAt ?? 0
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func status() -> String {

		let person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId())
		return person?.status ?? ""
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func keepMedia() -> Int {

		let person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId())
		return person?.keepMedia ?? KeepMedia.Forever
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func networkPhoto() -> Int {

		let person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId())
		return person?.networkPhoto ?? Network.All
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func networkVideo() -> Int {

		let person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId())
		return person?.networkVideo ?? Network.All
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func networkAudio() -> Int {

		let person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId())
		return person?.networkAudio ?? Network.All
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func wallpaper() -> String {

		let person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId())
		return person?.wallpaper ?? ""
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func loginMethod() -> String {

		let person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId())
		return person?.loginMethod ?? ""
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func update(status: String) {

		if let person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId()) {
			person.update(status: status)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func update(keepMedia: Int) {

		if let person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId()) {
			person.update(keepMedia: keepMedia)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func update(networkPhoto: Int) {

		if let person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId()) {
			person.update(networkPhoto: networkPhoto)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func update(networkVideo: Int) {

		if let person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId()) {
			person.update(networkVideo: networkVideo)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func update(networkAudio: Int) {

		if let person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId()) {
			person.update(networkAudio: networkAudio)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func update(wallpaper: String) {

		if let person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId()) {
			person.update(wallpaper: wallpaper)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func update(oneSignalId: String) {

		if let person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId()) {
			person.update(oneSignalId: oneSignalId)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func update(lastActive: Int) {

		if let person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId()) {
			person.update(lastActive: lastActive)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func update(lastTerminate: Int) {

		if let person = realm.object(ofType: Person.self, forPrimaryKey: AuthUser.userId()) {
			person.update(lastTerminate: lastTerminate)
		}
	}
}
