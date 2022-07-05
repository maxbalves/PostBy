CAPSTONE PROJECT
===

# PostBy

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
App allows users to see and create posts for their timeline. Each timeline will display the most recently created posts. App will allow users to open a map and see where exactly each post originated from.

### App Evaluation
- **Category:** Social Networking
- **Mobile:** Mobile is important because the app will be a social networking platform that users can quickly check and engage on. The mobile phone's location will be important for the app's features.
- **Story:** Users will be able to see posts from users around the world, which can create more community, allow for meetups, and create local entertainment.
- **Market:** Any individual with a mobile phone is able to benefit from the app for their own entertainment.
- **Habit:** The app can be used daily in order to see new messages and the posts around the user. It could create a habit of checking/creating posts everyday.
- **Scope:** On the most basic level, the app will demonstrate a timeline for creating and viewing posts and showing pins of where the posts where made. Users will be able to sort their timeline by newest, trending, or close by posts. As stretch goals, the app could the ability to change locations and see posts from other places, and group pins together as you zoom out of a zone.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* Users can see timeline of posts
    * Sort posts between Trending, Newest, and Close By
        * **Newest**: sort by chronological order of posts in the day
        * **Trending**: sort the week's post by descending order of likes
        * **Close By**: fetch posts of the week only around the users mile radius, and sort by chronological order 
* Users can create/view posts
* Users can access a map that shows the posts' locations
* Users can login and register accounts using Parse
    * Passwords are encrypted/hashed
* Users can add a profile picture
* Clicking on a post in the map screen, brings you to detail screen of that post
* Users can delete their account and data

**Optional Nice-to-have Stories**

* Users can edit/delete their own posts
* Users can choose privacy settings
    * Hide location or username
* Users can like or dislike posts
    * Posts that have a great dislike to like ratio are auto removed
* Users can comment on posts
* As user zooms out, pins are grouped for better display
* Old posts are automatically removed from the database.

### 2. Screen Archetypes

* Login/Sign up screen
   * User can login
   * User can sign up
* Home/Timeline screen
    * Users can see post timeline and change the posts sorting
    * Users can like or dislike posts
    * Users can switch between New, Trending, and Close By tab
* Create/Compose post screen
    * Users can create posts
    * Users can choose privacy settings
* Map screen
    * Users can access a map that shows all posts’ locations
    * As user zooms out, pins are grouped for better display
    * Clicking on a link displays a post's details
* Post Detail screen
    * Users can like or dislike post
    * Users can comment on posts
    * Users can edit / delete post if its their own
    * Users can click on info icon to see where post was created
* Settings Screen
    * Users can delete account
    * Users can set a profile picture
    * (Stretch) Users can set privacy settings



### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Home Feed
* Map Screen
* Create Screen

**Flow Navigation** (Screen to Screen)

* Login/Signup screen
   => Home Feed
* Home/Timeline screen
   => Post Detail Screen
   => Settings Screen
* Create/Compose post screen
   => Home Feed (after creating post)
* Map screen
   => Post Detail Screen (on clicked post)
* Post Detail Screen
   => Home Screen (go back)
   => Map Screen (shows post location)

## Wireframes
<img src="https://github.com/maxbalves/PostBy/blob/main/HandWireframe.png?raw=true" width=600>

### [BONUS] Digital Wireframes & Mockups

### [BONUS] Interactive Prototype

## Schema 
### Models

**User**
| Property       | Type     | Description                                 |
| -------------- | -------- | ------------------------------------------- |
| objectId       | String   | unique id for the user (default field)      |
| username       | String   | User's username to log in                   |
| password       | String   | Users hashed/encrypted password             |
| profilePicture | File     | User's profile picture                      |
| email          | String   | User's email address(default field)         |
| createdAt      | DateTime | unique id for the user post (default field) |
| updatedAt      | DateTime | unique id for the user post (default field) |


**Post**
| Property      | Type            | Description                                 |
| ------------- | --------------- | ------------------------------------------- |
| objectId      | String          | unique id for the user post (default field) |
| author        | Pointer to User | post author                                 |
| text          | String          | post text by author                         |
| commentsCount | Number          | post author                                 |
| likesCount    | Number          | post author                                 |
| dislikesCount | Number          | post author                                 |
| latitude      | Number          | user's latitude when posted                 |
| longitude     | Number          | user's longitude when posted                |
| createdAt     | DateTime        | unique id for the user post (default field) |
| updatedAt     | DateTime        | unique id for the user post (default field) |

**Comment**
| Property      | Type            | Description                                 |
| ------------- | --------------- | ------------------------------------------- |
| objectId      | String          | unique id for the comment (default field)   |
| postId        | Pointer to Post | post where the comment was done on          |
| author        | Pointer to User | comment author                              |
| text          | String          | comment text by author                      |
| createdAt     | DateTime        | unique id for the user post (default field) |
| updatedAt     | DateTime        | unique id for the user post (default field) |

### Networking
- Login/Sign up screen
    - (Read/GET) Get user data
    - (Create/POST) Create a new user
- Home/Timeline screen
    - (Read/GET) Get posts for timeline
    - (Create/POST) Create new dislike on post
    - (Create/POST) Create new comment on post
- Create/Compose post screen
    - (Create/POST) Create new post
- Map screen
    - (Read/GET) Get posts for map
- Post Detail screen
    - (Create/POST) Create new like on post
    - (Create/POST) Create new dislike on post
    - (Create/POST) Create new comment on post
    - (Update/PUT) Update own post
    - (Delete) Delete dislike/like on post
    - (Delete) Delete post
- Settings Screen
    - (Delete) Delete account, posts, data, etc...
