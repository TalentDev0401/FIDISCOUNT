//
//  ComposeBenefitVC.swift
//  Fid
//
//  Created by CROCODILE on 26.04.2021.
//

import RealmSwift

//-------------------------------------------------------------------------------------------------------------------------------------------------
class BenefitChatsView: BaseVC {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var backImg: UIImageView!

    private var tokenMembers: NotificationToken? = nil
    private var tokenChats: NotificationToken? = nil

    private var members    = realm.objects(Member.self).filter(falsepredicate)
    private var chats    = realm.objects(Chat.self).filter(falsepredicate)
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    override func viewDidLoad() {

        super.viewDidLoad()
        
        let back = UIImage(named: "back")
        backImg.image = back?.withRenderingMode(.alwaysTemplate)
        backImg.tintColor = UIColor(hexString: "#27bdb1")
                
        NotificationCenter.addObserver(target: self, selector: #selector(loadMembers), name: NOTIFICATION_USER_LOGGED_IN)
        NotificationCenter.addObserver(target: self, selector: #selector(actionCleanup), name: NOTIFICATION_USER_LOGGED_OUT)

        tableView.register(UINib(nibName: "ChatsCell", bundle: nil), forCellReuseIdentifier: "ChatsCell")

        tableView.tableFooterView = UIView()

        if (AuthUser.userId() != "") {
            loadMembers()
        }
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)

        if (AuthUser.userId() == "") {
            let alert = UIAlertController(title: "Login required", message: "You should login or register for chat with the other users.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { void in
                self.tabBarController?.selectedIndex = 0
            }))

            alert.addAction(UIAlertAction(title: "Register", style: .default, handler: { void in
                let register = self.storyboard?.instantiateViewController(identifier: "RegisterVC") as! RegisterVC
                self.navigationController?.popPushToVC(ofKind: RegisterVC.self, pushController: register)
            }))
                    
            self.present(alert, animated: true, completion: nil)
        }
    }

    // MARK: - Realm methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    @objc func loadMembers() {

        let predicate = NSPredicate(format: "userId == %@ AND isActive == YES", AuthUser.userId())
        members = realm.objects(Member.self).filter(predicate)

        tokenMembers?.invalidate()
        members.safeObserve({ changes in
            self.loadChats()
        }, completion: { token in
            self.tokenMembers = token
        })
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func loadChats(text: String = "") {

        let predicate1 = NSPredicate(format: "objectId IN %@ AND lastMessageAt != 0", Members.chatIds())
        let predicate2 = NSPredicate(format: "isDeleted == NO AND isArchived == NO AND isGroupDeleted == NO")
        let predicate3 = (text != "") ? NSPredicate(format: "details CONTAINS[c] %@", text) : NSPredicate(value: true)

        let predicate = NSCompoundPredicate(type: .and, subpredicates: [predicate1, predicate2, predicate3])
        chats = realm.objects(Chat.self).filter(predicate).sorted(byKeyPath: "lastMessageAt", ascending: false)

        tokenChats?.invalidate()
        chats.safeObserve({ changes in
            self.refreshTableView()
        }, completion: { token in
            self.tokenChats = token
        })
    }

    // MARK: - Refresh methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func refreshTableView() {

        tableView.reloadData()
        self.refreshTabCounter()
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func refreshTabCounter() {

        var total: Int = 0

        for chat in chats {
            total += chat.unreadCount
        }

        let item = tabBarController?.tabBar.items?[2]
        item?.badgeValue = (total != 0) ? "\(total)" : nil

        UIApplication.shared.applicationIconBadgeNumber = total
    }

    // MARK: - User actions    
    @IBAction func goback(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    @IBAction func actionCompose(_ sender: Any) {
        
        performSegue(withIdentifier: "compose_benefit", sender: self)
    }
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    func actionNewChat() {

        actionCompose(self)
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func actionRecentUser(userId: String) {
        let chatId = Singles.create(userId)
        actionChatPrivate(chatId: chatId, recipientId: userId)
                
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func actionChatPrivate(chatId: String, recipientId: String) {
        
        let privateChatView = RCPrivateChatView(chatId: chatId, recipientId: recipientId)
        privateChatView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(privateChatView, animated: true)
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func actionChatGroup(chatId: String) {

        let groupChatView = RCGroupChatView(chatId: chatId)
        groupChatView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(groupChatView, animated: true)
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func actionDelete(at indexPath: IndexPath) {

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { action in
            let chat = self.chats[indexPath.row]
            Details.update(chatId: chat.objectId, isDeleted: true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func actionMore(at indexPath: IndexPath) {

        let chat = self.chats[indexPath.row]
        let isMuted = chat.mutedUntil > Date().timestamp()
        let titleMute = isMuted ? "Unmute" : "Mute"

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: titleMute, style: .default) { action in
            if (isMuted)    { self.actionUnmute(at: indexPath)    }
            if (!isMuted)    { self.actionMute(at: indexPath)    }
        })
        alert.addAction(UIAlertAction(title: "Archive", style: .default) { action in
            let chat = self.chats[indexPath.row]
            Details.update(chatId: chat.objectId, isArchived: true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func actionUnmute(at indexPath: IndexPath) {

        let chat = self.chats[indexPath.row]
        Details.update(chatId: chat.objectId, mutedUntil: 0)
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func actionMute(at indexPath: IndexPath) {

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "10 hours", style: .default) { action in
            self.actionMute(at: indexPath, until: 10)
        })
        alert.addAction(UIAlertAction(title: "7 days", style: .default) { action in
            self.actionMute(at: indexPath, until: 168)
        })
        alert.addAction(UIAlertAction(title: "1 month", style: .default) { action in
            self.actionMute(at: indexPath, until: 720)
        })
        alert.addAction(UIAlertAction(title: "1 year", style: .default) { action in
            self.actionMute(at: indexPath, until: 8760)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func actionMute(at indexPath: IndexPath, until hours: Int) {

        let seconds = TimeInterval(hours * 60 * 60)
        let dateUntil = Date().addingTimeInterval(seconds)
        let mutedUntil = dateUntil.timestamp()

        let chat = chats[indexPath.row]
        Details.update(chatId: chat.objectId, mutedUntil: mutedUntil)
    }

    // MARK: - Cleanup methods
    //---------------------------------------------------------------------------------------------------------------------------------------------
    @objc func actionCleanup() {

        tokenMembers?.invalidate()
        tokenChats?.invalidate()

        members    = realm.objects(Member.self).filter(falsepredicate)
        chats    = realm.objects(Chat.self).filter(falsepredicate)

        refreshTableView()
    }
}

// MARK: - SelectUserDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension BenefitChatsView: SelectUserDelegate {

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func didSelectUser(person: Person) {

        let chatId = Singles.create(person.objectId)
        actionChatPrivate(chatId: chatId, recipientId: person.objectId)
    }
}

// MARK: - UIScrollViewDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension BenefitChatsView: UIScrollViewDelegate {

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

        view.endEditing(true)
    }
}

// MARK: - UITableViewDataSource
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension BenefitChatsView: UITableViewDataSource {

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return chats.count
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatsCell", for: indexPath) as! ChatsCell

        let chat = chats[indexPath.row]
        cell.bindData(chat: chat)
        cell.loadImage(chat: chat, tableView: tableView, indexPath: indexPath)

        return cell
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        return true
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let actionDelete = UIContextualAction(style: .destructive, title: "Delete") {  action, sourceView, completionHandler in
            self.actionDelete(at: indexPath)
            completionHandler(false)
        }

//        let actionMore = UIContextualAction(style: .normal, title: "More") {  action, sourceView, completionHandler in
//            self.actionMore(at: indexPath)
//            completionHandler(false)
//        }

        actionDelete.image = UIImage(systemName: "trash")
//        actionMore.image = UIImage(systemName: "ellipsis")

        return UISwipeActionsConfiguration(actions: [actionDelete])//, actionMore
    }
}

// MARK: - UITableViewDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension BenefitChatsView: UITableViewDelegate {

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        let chat = chats[indexPath.row]

        if (chat.isGroup) {
            actionChatGroup(chatId: chat.objectId)
        }
        if (chat.isPrivate) {
            actionChatPrivate(chatId: chat.objectId, recipientId: chat.userId)
        }
    }
}

// MARK: - UISearchBarDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension BenefitChatsView: UISearchBarDelegate {

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        loadChats(text: searchText)
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func searchBarTextDidBeginEditing(_ searchBar_: UISearchBar) {

        searchBar.setShowsCancelButton(true, animated: true)
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func searchBarTextDidEndEditing(_ searchBar_: UISearchBar) {

        searchBar.setShowsCancelButton(false, animated: true)
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func searchBarCancelButtonClicked(_ searchBar_: UISearchBar) {

        searchBar.text = ""
        searchBar.resignFirstResponder()
        loadChats()
    }

    //---------------------------------------------------------------------------------------------------------------------------------------------
    func searchBarSearchButtonClicked(_ searchBar_: UISearchBar) {

        searchBar.resignFirstResponder()
    }
}
