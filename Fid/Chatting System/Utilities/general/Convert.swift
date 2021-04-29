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
class Convert: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func dateToShort(_ date: Date) -> String {

		return DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .none)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func timestampToMediumTime(_ timestamp: Int) -> String {

		let date = Date.date(timestamp: timestamp)
		return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func timestampToDayMonthTime(_ timestamp: Int) -> String {

		let date = Date.date(timestamp: timestamp)

		let formatter = DateFormatter()
		formatter.dateFormat = "dd MMMM, HH:mm"

		return formatter.string(from: date)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func timestampToElapsed(_ timestamp: Int) -> String {

		var elapsed = ""

		let date = Date.date(timestamp: timestamp)
		let seconds = Date().timeIntervalSince(date)

		if (seconds < 60) {
			elapsed = "Just now"
		} else if (seconds < 60 * 60) {
			let minutes = Int(seconds / 60)
			let text = (minutes > 1) ? "mins" : "min"
			elapsed = "\(minutes) \(text)"
		} else if (seconds < 24 * 60 * 60) {
			let hours = Int(seconds / (60 * 60))
			let text = (hours > 1) ? "hours" : "hour"
			elapsed = "\(hours) \(text)"
		} else if (seconds < 7 * 24 * 60 * 60) {
			let formatter = DateFormatter()
			formatter.dateFormat = "EEE"
			elapsed = formatter.string(from: date)
		} else {
			let formatter = DateFormatter()
			formatter.dateFormat = "dd.MM.yy"
			elapsed = formatter.string(from: date)
		}

		return elapsed
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func timestampToCustom(_ timestamp: Int?) -> String {

		guard let timestamp = timestamp else { return "" }

		let date = Date.date(timestamp: timestamp)
		let seconds = Date().timeIntervalSince(date)

		let formatter = DateFormatter()
		if (seconds < 24 * 60 * 60) {
			formatter.dateFormat = "HH:mm"
		} else if (seconds < 7 * 24 * 60 * 60) {
			formatter.dateFormat = "EEE"
		} else {
			formatter.dateFormat = "dd.MM.yy"
		}

		return formatter.string(from: date)
	}
}
