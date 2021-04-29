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

import FirebaseStorage

//-------------------------------------------------------------------------------------------------------------------------------------------------
class FireStorage: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func upload(dir: String, name: String, ext: String, data: Data, completion: @escaping (_ error: Error?) -> Void) {

		let storage = "\(dir)/\(name).\(ext)"
		let reference = Storage.storage().reference(withPath: storage)

		reference.putData(data, metadata: nil) { metadata, error in
			completion(error)
		}
	}
    
    class func uploadJPEGTYPE(dir: String, name: String, ext: String, data: Data, completion: @escaping (_ error: Error?) -> Void) {


        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let reference = Storage.storage().reference(withPath: dir).child("\(name)")

        reference.putData(data, metadata: metadata) { metadata, error in
            completion(error)
        }
    }

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func download(dir: String, name: String, ext: String, completion: @escaping (_ path: String, _ error: Error?) -> Void) {

		let storage = "\(dir)/\(name).\(ext)"
		let reference = Storage.storage().reference(withPath: storage)

		let file = "\(name).\(ext)"
		let path = Dir.document(dir, and: file)
		let url = URL(fileURLWithPath: path)

		reference.write(toFile: url) { url, error in
			if (error != nil) {
				File.remove(path: path)
				completion("", error)
			} else {
				completion(path, nil)
			}
		}
	}
}
