//
//  HomeTableViewController.swift
//  blueit
//
//  Created by Mac Mini on 11/29/22.
//

import UIKit

class HomeTableViewController: UITableViewController {
    public static var client: HomeTableViewController? = nil
    var num_posts = 0
    var posts: [[String: Any]]? = nil
    public static var feedEndpoint = "/best"
    var blueitArray = [NSDictionary]()
    
    let myRefreshControl = UIRefreshControl()
    
    
    
    override func viewDidLoad() {
        HomeTableViewController.client = self
        super.viewDidLoad()
        
        loadfeed()
        
        myRefreshControl.addTarget(self, action: #selector(loadfeed), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
        
    }
    
    
    func loadPosts (amount: Int) {
        guard amount > 0 else {
            return
        }
        Task {
            num_posts = amount
            print("load: \(HomeTableViewController.feedEndpoint)")
            posts = try await RedditAPICaller.client.getPosts(limit: num_posts, endPoint: HomeTableViewController.feedEndpoint)
            self.tableView.reloadData()
            self.myRefreshControl.endRefreshing()
            //performDebug()
        }
    }
    
    @objc func loadfeed() {
        
        print("API token = " + (RedditAPICaller.sessionToken ?? "nil"))
        loadPosts(amount: 10)
    }
    @objc func loadmorefeed(){
        loadPosts(amount: num_posts+10)
    }
    
    @IBAction func onLogout(_ sender: Any) {
        
        self.dismiss(animated: true)
        UserDefaults.standard.set(nil, forKey: "sessionToken")
 	       
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath) as! blueitTableViewCell
        
        let post = RedditAPICaller.client.accessPost(post_list: posts, index: indexPath.row)
        
        cell.subreddit.text = post?["subreddit_name_prefixed"] as? String ?? "no subreddit_name_prefixed"//subreddit_name_prefixed
        cell.authorlabel.text = post?["author"] as? String ?? "no author" //author
        cell.headLine.text = post?["title"] as? String ?? "no title" //title
        cell.content.text = post?["selftext"] as? String ?? "no selftext" //selftext
        
        cell.imageLink.text = post?["url_overridden_by_dest"] as? String ?? "______________________________"
        
        
        print("got post link \(post?["url_overridden_by_dest"] ?? "nil")")
        
        return cell
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return posts?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let clicked_post = RedditAPICaller.client.accessPost(post_list: posts, index: indexPath.row)
        let clicked_post_id = clicked_post?["id"] as? String
        print(clicked_post_id as Any)
        guard clicked_post_id != nil else {
            return
        }
        commentTableViewController.post_id = clicked_post_id
        self.performSegue(withIdentifier: "goToComments", sender: nil)
        
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
        if indexPath.row + 1 == posts?.count {
            loadmorefeed()
        }
    }
    func performDebug() {
        Task {
            //log posts
            print("=====POSTS=====")
            print(posts as Any)
            
            //RedditAPICaller.client.accessPost(postList: posts, index: Int)
            //gets the post info at an index
            let first_post = RedditAPICaller.client.accessPost(post_list: posts, index: 0)
            //you need the id of a post to get its comments
            //getComments only gets the top level comments (cant get replys to comments yet)
            let first_post_id = first_post?["id"]
            let comments = try await RedditAPICaller.client.getComments(article_id: first_post_id as? String, limit: 10)
            //log comments
            print("=====COMMENTS=====")
            print(comments as Any)
            //how to access a post's data
            print("first post keys: ", first_post?.keys as Any)
            print("first post title: ", first_post?["title"] as Any)
            print("first post upvote status: {", type(of: first_post?["likes"]) , "}")
            
            //how to check if a post is upvoted or not
            let upvote_status = first_post?["likes"] as? Bool
            if upvote_status == true {
                print("upvoted")
            } else if upvote_status == nil {
                print("not voted")
            } else if upvote_status == false {
                print("downvoted")
            }
            
            //how to vote
            //-1 is downvote, 0 is remove vote, 1 is upvote
            _ = try await RedditAPICaller.client.votePost(id: first_post_id as? String, dir: 1)
            
            let first_comment = RedditAPICaller.client.accessComment(comment_list: comments, index: 0)
            print("first comment text: \(first_comment?["body"] ?? "nil")")
            _ = try await RedditAPICaller.client.voteComment(id: first_comment?["id"] as? String, dir: 1)
            
            //print user
            print("=====USER=====")
            let user = try await RedditAPICaller.client.getIdentity()
            print(user as Any)
            print(user?.keys as Any)
            print(user?["id"] as Any)
            print(user?["name"] as Any)
            let userPosts = try await RedditAPICaller.client.getUserPosts(limit: 1, username: user?["name"] as? String)
            let userFirstPost = RedditAPICaller.client.accessPost(post_list: userPosts, index: 0)
            print(userFirstPost?["title"] as Any)
            
            //dummy post
            let dummy_post = try await RedditAPICaller.client.submitTextPost(subreddit: "test", title: "test", text: "test")
            print(dummy_post as Any)
        }
    }
}
