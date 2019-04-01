//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Wade Li on 3/31/19.
//  Copyright © 2019 Wade Li. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    
    var posts = [PFObject]()
    @IBOutlet var tableV: UITableView!
    let commentB = MessageInputBar()
    var showsCB = false
    var selectedP: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentB.inputTextView.placeholder = "Add a comment..."
        commentB.sendButton.title = "Post"
        commentB.delegate = self
        tableV.delegate = self
        tableV.dataSource = self
        tableV.keyboardDismissMode = .interactive
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @objc func keyboardWillBeHidden(note: Notification) {
        commentB.inputTextView.text = nil
        showsCB = false
        becomeFirstResponder()
    }
    
    override var inputAccessoryView: UIView? {
        return commentB
    }
    
    override var canBecomeFirstResponder: Bool {
        return showsCB
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let query = PFQuery(className: "Posts")
        query.includeKeys(["author", "comments", "comments.author"])
        query.limit = 20
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts = posts!
                self.tableV.reloadData()
            }
        }
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedP
        comment["author"] = PFUser.current()!
        selectedP.add(comment, forKey: "comments")
        selectedP.saveInBackground { (success, error) in
            if success {
                print("Comment saved")
            }
            else {
                print("Error saving comment")
            }
        }
        tableV.reloadData()
        commentB.inputTextView.text = nil
        showsCB = false
        becomeFirstResponder()
        commentB.inputTextView.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        return comments.count + 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        if indexPath.row == 0 {
            let cell = tableV.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            let user = post["author"] as! PFUser
            cell.usernameL.text = user.username
            cell.commentL.text = post["caption"] as? String
            let imageF = post["image"] as! PFFileObject
            let urlS = imageF.url!
            let url = URL(string: urlS)!
            cell.PhotoV.af_setImage(withURL: url)
            return cell
        }
        else if indexPath.row <= comments.count {
            let cell = tableV.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            let comment = comments[indexPath.row - 1]
            cell.commentL.text = comment["text"] as? String
            let user = comment["author"] as! PFUser
            cell.nameL.text = user.username
            return cell
        }
        else {
            let cell = tableV.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        if indexPath.row == comments.count + 1 {
            showsCB = true
            becomeFirstResponder()
            commentB.inputTextView.becomeFirstResponder()
            selectedP = post
        }
    }
    
    @IBAction func onLogout(_ sender: Any) {
        PFUser.logOut()
        let main = UIStoryboard(name: "Main", bundle: nil)
        let lVC = main.instantiateViewController(withIdentifier: "LoginViewController")
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.window?.rootViewController = lVC
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
