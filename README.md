# Blueit

Original App Design Project - Group 13: Swift Scorpions  
===

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
In this project, we design a replication of the app named "Reddit" and implement some of the functionalites to create "Blueit". The app "Reddit" is a social media platform where the communities are divided into "subreddits" based on topics and interests. Users are able to post images, links or text annonymously on subreddits and everyone has the capability to vote, such as upvote or downvote, 

### App Evaluation
[Evaluation of your app across the following attributes]
- **Category: Social Media**
- **Mobile: On Iphone using Swift**
- **Story: The app "Blueit" will be a social media platform where the communities are divided into "subreddits" based on topics and interests**
- **Market: For people interested in seeing news and topics made by users around the world about a specific topic. It is a hub full of different subjects that anyone can view providing you with a place to ask questions**
- **Habit: Numerous times throughout the day, users can post. Users can see what others are asking and can view and share links or text posts for people to see throughout time. By scrolling through endless posts you will form a habit listening to what people are saying.**
- **Scope: Everyone can download Blueit**

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* User will be able log create account and login
* Users are able to set their profile picture
* User will be able to view trending posts
* User will be able to view comments on posts
* User will be able to post text, links, or images to “Subreddits”
* User will be able to comment on posts
* User will be able to upvote or downvote on subreddits

**Optional Nice-to-have Stories**

* Users can be able to send messages to other users
* Users are able to use the camera to take a picture and set their profile picture
* Users can see the date and time the post was made along with the comments
* Settings page where you can change username, password, or email.

### 2. Screen Archetypes

* Opening Screen
   * When opening the Blueit app, the user will be shown the logo for the app.
* Login Screen
   * When first opening the Blueit, the user will be shown to the login screen to sign up or sign in. Unless they log out, the user will remain logged in when they reopen the app.
* Register Screen
   * Each user is required to click the sign up button if this is their first time using the app. They will then sign up for the application through the signup portal.
   * Users are able to sign up new accounts in the register screen.
* Feed Screen
   * Here, the user will see subreddit posts in a feed style. The user can select on any of the post entries to view it.
   * User can press the upvote or downvote option
   * User sees the most popular post on first main screen
* Profile Screen
   * User can view and change their settings here such as profile picture.
* Post Screen
   * User post a about a topic in a specific subreddit. There will be options to add pictures, links, etc.  

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Login Portal
* View News Page/ current trending topics
* Look at detail about trending topics, and be able to view comments

Optional

* Direct Messages
* Settings
* Search Bar

**Flow Navigation** (Screen to Screen)

* Login → 
* Homescreen(trending topics) → 
* View specific subreddit → 
* Write thoughts/comments → 
* Post thoughts/comments → 
* Being able to upvote/downvote → 
* press back to return to homescreen → 
* ability to logout --

## Wireframes
[Add picture of your hand sketched wireframes in this section]
<img src="https://i.imgur.com/rvBAxge.png" width=600>
<img src="https://i.imgur.com/6Kn6S1r.png" width=600>
<img src="https://i.imgur.com/J8AuQKR.png" width=600>
<img src="https://i.imgur.com/livy7px.png" width=600>
<img src="https://i.imgur.com/cUivX7s.png" width=600>
<img src="https://i.imgur.com/g4dAZEV.png" width=600>

### [BONUS] Digital Wireframes & Mockups

### [BONUS] Interactive Prototype

## Schema 
[This section will be completed in Unit 9]
### Models
Login
Property	Type	Description
Logo	Image/File	Blueit Logo pulled from files
Username	String	Username pulled from API
Password	String	Password pulled from API
Login	Button	Checks authentication to allow access
Register	Button	Redirects user to different screen to register to use app
Blueit	Title/string	Title of the App

Register
Property	Type	Description
Logo	Image/File	Blueit Logo pulled from files
Username	String	Username pulled from API
Password	String	Password pulled from API
First Name	String	Input from the user 
Last name	String	Input from the user
Register	Button	Allows user to register their account
Blueit	Title/string	Title of the App

Homepage
Property	Type	Description
Logo	Image/File	Blueit Logo pulled from files
Logout	Button	Allows user to logout from app
Profile	Button	Allows user to access  their account info
Headline	String	Latest feed headline pulled from API
Information/element	String	Post from corresponding headline pulled from API
Image	Image	Pulled from API correlating to the post
Time	Integer/let	Time of post pulled from API
Blueit	Title/string	Title of the App

Profile
Property	Type	Description
Logo	Image/File	Blueit Logo pulled from files
Username	String	Username pulled from API
Headline	String	Latest post made by user pulled from api
Information/element	String	Post from corresponding headline pulled from API
Time	Let/Integer	Time of post pulled from API
Logout	Button	Allows user to logout from their account
Homescreen	Button	Allows user to return to main feed screen
Blueit	Title/string	Title of the App

Posting
Property	Type	Description
Logo	Image/File	Blueit Logo pulled from files
Post Title	Label/string	Allows user to input their headline title
Subreddit	Label/string	Allows user to choose which subreddit from api to post
Post Content	String/label	Input from the user 
Exit	Button	Allows user to exit from post to return to feed screen
Post	Button	Allows user to post to the feed
Blueit	Title/string	Title of the App



[Add table of models]
### Networking
- [Add list of network requests by screen ]
- [Create basic snippets for each Parse network request]
- [OPTIONAL: List endpoints if using existing API such as Yelp]
