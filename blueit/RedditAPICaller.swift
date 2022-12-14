//
//  RedditAPICaller.swift
//  blueit
//
//  Created by Lucas Mattos on 11/19/22.
//

import UIKit

let REDIRECT_URI = "blueit://a"
let CLIENT_ID = "fGLcC77TVgO0idNwa_TNqQ" //public app client id
let OAUTH_ENDPOINT = "https://oauth.reddit.com"
let TOKEN_ACCESS_ENDPOINT = "https://www.reddit.com/api/v1/access_token"

let HEADERS = [
    "User-Agent": "blueit for reddit",
    "Content-Type": "application/x-www-form-urlencoded"
]

let loginString = "\(CLIENT_ID):"
let loginData = loginString.data(using: .utf8)
let base64LoginString = loginData!.base64EncodedString()

extension URL {
    //used for getting info from redirect uri (like session token)
    func valueOf(_ queryParameterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParameterName })?.value
    }
}

extension Array {
    subscript (safe index: Index) -> Element? {
        0 <= index && index < count ? self[index] : nil
    }
}

class RedditAPICaller: NSObject {
    
    //for calling methods in this class in other files
    static let client = RedditAPICaller()
    //stores session token
    public static var sessionToken: String? = nil
    var window: UIWindow?
    
    
    func setSessionToken(openURLContexts URLContexts: Set<UIOpenURLContext>) {
        //check if valid url
        guard let url = URLContexts.first?.url else {
            print("[BRUH] invalid url")
            return
        }
        //store auth code
        if let code = url.valueOf("code") {
            var request = URLRequest(url: URL(string: TOKEN_ACCESS_ENDPOINT)!)
            //set up all the request stuff
            request.httpMethod = "POST"
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems = [
                URLQueryItem(name: "grant_type", value: "authorization_code"),
                URLQueryItem(name: "code", value: code),
                URLQueryItem(name: "redirect_uri", value: REDIRECT_URI),
            ]
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            request.allHTTPHeaderFields = HEADERS
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
            let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
                //print(response!)
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                    RedditAPICaller.sessionToken = json["access_token"]! as? String
                    UserDefaults.standard.set(RedditAPICaller.sessionToken, forKey: "sessionToken")
                    //go to feed if successful login
                    DispatchQueue.main.async {
                        LoginViewController.client?.goToFeed()
                    }
                } catch {
                    print("[BRUH] error serializing json data")
                }
            })
            
            task.resume()
        } else {
            print("[BRUH] error when retrieving auth code: " + (url.valueOf("error") ?? "missing error"))
        }
        
        
        
        return
    }
    
    func get(endPoint: String, params: Dictionary<String, String>) async throws -> Any? {
        if RedditAPICaller.sessionToken == nil {
            print("[BRUH] attemped api call with no session token")
            return nil
        }
        
        var queryItems: [URLQueryItem] = []
        for i in params.keys {
            queryItems.append(URLQueryItem(name: i, value: params[i]))
        }
        
        var urlComps = URLComponents(string: OAUTH_ENDPOINT + endPoint)!
        urlComps.queryItems = queryItems
        var request = URLRequest(url: urlComps.url!)
        
        request.allHTTPHeaderFields = HEADERS
        request.addValue("Bearer " + RedditAPICaller.sessionToken!, forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        var json = try JSONSerialization.jsonObject(with: data, options: []) as Any
        
        while json as? NSDictionary != nil {
            if (json as! NSDictionary)["data"] != nil {
                json = (json as! NSDictionary)["data"] as Any
            } else if (json as! NSDictionary)["children"] != nil {
                json = (json as! NSDictionary)["children"] as Any
            } else {
                break
            }
        }
        
        return json as Any?
    }
    func getIdentity() async throws -> [String: Any]? {
        return try await self.get(endPoint: "/api/v1/me", params: [:]) as? [String: Any]
    }
    func getPosts(limit: Int, endPoint: String) async throws -> [[String: Any]]? {
        return try await self.get(endPoint: endPoint, params: ["limit":String(limit)]) as? [[String: Any]]
    }
    func getUserPosts(limit: Int, username: String?) async throws -> [[String: Any]]? {
        guard username != nil else {
            return nil
        }
        return try await self.get(endPoint: "/user/\(username!)/submitted", params: ["limit":String(limit)]) as? [[String: Any]]
    }
    //    func getBestPosts(limit: Int) async throws -> [[String: Any]]? {
    //        return try await self.getPosts(limit: limit, endPoint: "/best")
    //    }
    func accessPost(post_list: [[String:Any]]?, index: Int) -> [String:Any]? {
        if post_list == nil {
            print("no posts")
            return nil
        }
        if post_list!.count <= index {
            print("index out of bounds: \(post_list!.count) <= \(index)")
            return nil
        }
        guard let nth_post = post_list?[index]["data"] as? [String:Any] else {
            print("could not get post")
            return nil
        }
        return nth_post
    }
    func getComments(article_id: String?, limit: Int, depth: Int = 0, sort: String = "top") async throws -> [[String: Any]]? {
        if article_id == nil {
            print("no article id")
            return nil
        }
        var comments = try await self.get(endPoint: "/comments/"+article_id!, params: [
            "limit":String(limit),
            "depth":String(depth),
            "sort":sort
        ]) as? [[String: Any]]
        comments?.removeFirst()
        guard let comments = comments?[0]["data"] as? [String:Any] else {
            print("could not get comment A")
            return nil
        }
        guard let comments = comments["children"] as? [[String:Any]] else {
            print("could not get comment B")
            return nil
        }
        return comments
    }
    func accessComment(comment_list: [[String:Any]]?, index: Int) -> [String:Any]? {
        guard comment_list?.count ?? 0 > index else {
            print("comment index too big")
            return nil
        }
        
        guard let comment = comment_list?[index] as? [String:Any] else {
            print("could not get comment C")
            return nil
        }
        guard let comment = comment["data"] as? [String:Any] else {
            print("could not get comment D")
            return nil
        }
        return comment
    }
    func post(endPoint: String, params: Dictionary<String, String>) async throws -> HTTPURLResponse? {
        if RedditAPICaller.sessionToken == nil {
            print("[BRUH] attemped api call with no session token")
            return nil
        }
        
        var queryItems: [URLQueryItem] = []
        for i in params.keys {
            queryItems.append(URLQueryItem(name: i, value: params[i]))
        }
        
        var urlComps = URLComponents(string: OAUTH_ENDPOINT + endPoint)!
        urlComps.queryItems = queryItems
        var request = URLRequest(url: urlComps.url!)
        request.httpMethod = "POST"
        
        request.allHTTPHeaderFields = HEADERS
        request.addValue("Bearer " + RedditAPICaller.sessionToken!, forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        return response as? HTTPURLResponse
    }
    func votePost(id: String?, dir: Int) async throws -> Bool? {
        guard (id != nil) else {
            print("could not vote, nil id given")
            return nil
        }
        let full_id = "t3_\(id!)"
        guard (dir == -1 || dir == 0 || dir == 1) else {
            print("dir must be -1, 0, or 1")
            return nil
        }
        return try await self.post(endPoint: "/api/vote", params: [
            "dir":String(dir),
            "id":full_id
        ])?.statusCode == 200
    }
    func voteComment(id: String?, dir: Int) async throws -> Bool? {
        //id needs to start with t1_ for comments and t3_ for posts
        guard (id != nil) else {
            print("could not vote, nil id given")
            return nil
        }
        let full_id = "t1_\(id!)"
        guard (dir == -1 || dir == 0 || dir == 1) else {
            print("dir must be -1, 0, or 1")
            return nil
        }
        return try await self.post(endPoint: "/api/vote", params: [
            "dir":String(dir),
            "id":full_id
        ])?.statusCode == 200
    }
    func submitTextPost(subreddit: String, title: String, text: String) async throws -> Bool? {
        return try await self.post(endPoint: "/api/submit", params: [
            "sr":subreddit,
            "title":title,
            "kind":"self",
            "text":text,
        ])?.statusCode == 200
    }
    func submitLinkPost(subreddit: String, title: String, link: String) async throws -> Bool? {
        return try await self.post(endPoint: "/api/submit", params: [
            "sr":subreddit,
            "title":title,
            "kind":"link",
            "text":link,
        ])?.statusCode == 200
    }
}
