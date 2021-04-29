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
import CryptoKit

//-------------------------------------------------------------------------------------------------------------------------------------------------
extension String {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func sha1() -> String {

		let data = Data(self.utf8)
		let hash = Insecure.SHA1.hash(data: data)

		return hash.compactMap { String(format: "%02x", $0) }.joined()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func sha256() -> String {

		let data = Data(self.utf8)
		let hash = SHA256.hash(data: data)

		return hash.compactMap { String(format: "%02x", $0) }.joined()
	}
}
