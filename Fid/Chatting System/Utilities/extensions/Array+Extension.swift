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

//-------------------------------------------------------------------------------------------------------------------------------------------------
extension Array where Element: Hashable {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	mutating func removeDuplicates() {

		var array: [Element] = []

		for element in self {
			if !array.contains(element) {
				array.append(element)
			}
		}

		self = array
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	mutating func removeObject(_ element: Element) {

		var array = self

		while let index = array.firstIndex(of: element) {
			array.remove(at: index)
		}

		self = array
	}
}
