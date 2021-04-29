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
enum KeepMedia {

	static let Week		= 1
	static let Month	= 2
	static let Forever	= 3
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
enum Network {

	static let Manual	= 1
	static let WiFi		= 2
	static let All		= 3
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
enum MediaType {

	static let Photo	= 1
	static let Video	= 2
	static let Audio	= 3
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
enum MediaStatus {

	static let Unknown	= 0
	static let Loading	= 1
	static let Manual	= 2
	static let Succeed	= 3
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
enum AudioStatus {

	static let Stopped	= 1
	static let Playing	= 2
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
enum App {

	static let DefaultTab			= 0
	static let MaxVideoDuration		= TimeInterval(10)
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
let ONESIGNAL_APPID = "277d0aab-5925-475f-ba99-4af140776900"
//-------------------------------------------------------------------------------------------------------------------------------------------------
let SINCH_HOST = "sandbox.sinch.com"
let SINCH_KEY = "12eb4441-f90b-43f8-a0ed-3c3ff02e1c12"
let SINCH_SECRET = "LwwW9qmV40q1jBrEldaemw=="
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
let MESSAGE_TEXT = "text"
let MESSAGE_EMOJI = "emoji"
let MESSAGE_PHOTO = "photo"
let MESSAGE_VIDEO = "video"
let MESSAGE_AUDIO = "audio"
let MESSAGE_LOCATION = "location"
//---------------------------------------------------------------------------------
let STATUS_QUEUED = "Queued"
let STATUS_FAILED = "Failed"
let STATUS_SENT = "Sent"
let STATUS_READ = "Read"
//---------------------------------------------------------------------------------
let LOGIN_EMAIL = "Email"
let LOGIN_PHONE = "Phone"
//---------------------------------------------------------------------------------
let TEXT_SHARE_APP = "Check out https://related.chat"
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
let NOTIFICATION_APP_STARTED = "NotificationAppStarted"
let NOTIFICATION_USER_LOGGED_IN = "NotificationUserLoggedIn"
let NOTIFICATION_USER_LOGGED_OUT = "NotificationUserLoggedOut"
//---------------------------------------------------------------------------------
let NOTIFICATION_CLEANUP_CHATVIEW = "NotificationCleanupChatView"
//-------------------------------------------------------------------------------------------------------------------------------------------------
