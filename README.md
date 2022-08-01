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
App allows users to see and create posts for their timeline. Each timeline will display the most recently created posts. App will allow users to open a map and see where exactly each post originated from. The idea of the app is that users will be able to leave posts behind, wherever they explore.

### App Evaluation
- **Category:** Social Networking
- **Mobile:** Mobile is important because the app will be a social networking platform that users can quickly check and engage on. The mobile phone's location will be important for the app's features.
- **Story:** Users will be able to see posts from users around the world, which can create more community, allow for meetups, and create local entertainment.
- **Market:** Any individual with a mobile phone is able to benefit from the app for their own entertainment.
- **Habit:** The app can be used daily in order to see new messages and the posts around the user. It could create a habit of checking/creating posts everyday.
- **Scope:** On the most basic level, the app will demonstrate a timeline for creating and viewing posts and showing pins of where the posts where made. Users will be able to sort their timeline by newest or trending posts nearby.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* Users can see timeline of posts
    * Sort posts between Trending and Newest
        * **Newest**: sort the posts by chronological order, only within a 5-mile radius
        * **Trending**: sort the the newest posts by descending order of likes
* Users can create/view posts
* Users can access a map that shows the posts' locations
* Users can login and register accounts using Parse
* Users can add a profile picture
* Clicking on a post in the map screen, brings you to detail screen of that post
* Users can delete their account and data

**Optional Nice-to-have Stories**

* Users can edit/delete their own posts
* Users can choose privacy settings
    * Hide location, username, or profile picture.
* Users can like or dislike posts
* Users can comment on posts
* As user zooms out, pins are grouped for better display
* Old posts are automatically removed from the database.
* Users can see specific likes/dislikes/posts/comments made by them

### 2. Screen Archetypes

* Login/Sign up screen
   * User can login
   * User can sign up
* Home/Timeline screen
    * Users can see post timeline
    * Users can like or dislike posts
    * Users can switch between Newest or Trending sort
* Create/Compose post screen
    * Users can create posts
    * Users can choose privacy settings
* Map screen
    * Users can access a map that shows all posts’ locations
    * As user zooms out, pins are grouped for better display
    * Clicking on a pin displays a post's details
    * Users can manage the number of posts displayed at once on the map
* Post Detail screen
    * Users can like or dislike post
    * Users can comment on posts
    * Users can edit / delete post if its their own
    * Users can click on info icon to see where post was created
* Settings Screen
    * Users can delete account
    * Users can set a profile picture
    * Users can access Data Screen
* Data Screen
    * Users are able to see all their likes, dislikes, comments, and posts
    * Users can swipe to delete them



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
   => Create/Compose Screen (edit post)
* Settings Screen
   => Data Screen

## Wireframes (not updated to newest screens)
<img src="https://github.com/maxbalves/PostBy/blob/main/HandWireframe.png?raw=true" width=600>

## Schema 
### Models

**User**
| Property       | Type     | Description                                 |
| -------------- | -------- | ------------------------------------------- |
| objectId       | String   | unique id for the user (default field)      |
| username       | String   | user's username to log in                   |
| password       | String   | users hashed/encrypted password             |
| profilePicture | File     | user's profile picture                      |
| posts          | Relation | all user's posts                            |
| likes          | Relation | all posts the user liked                    |
| dislikes       | Relation | all posts the user disliked                 |
| comments       | Relation | all comments the user created               |
| email          | String   | user's email address(default field)         |
| createdAt      | DateTime | unique id for the user post (default field) |
| updatedAt      | DateTime | unique id for the user post (default field) |

**Post**
| Property       | Type            | Description                                 |
| -------------- | --------------- | ------------------------------------------- |
| objectId       | String          | unique id for the user post (default field) |
| author         | Pointer to User | post author                                 |
| text           | String          | post text by author                         |
| comments       | Relation        | all comments the post contains              |
| likes          | Relation        | all users who liked the post                |
| dislikes       | Relation        | all users who disliked the post             |
| likesCount     | Number          | Number of users who liked the post          |
| dislikesCount  | Number          | Number of users who disliked the post       |
| hideLocation   | Boolean         | Should post be hidden on maps or not        |
| hideUsername   | Boolean         | Should username be hidden or not            |
| hideProfilePic | Boolean         | Should profile picture be hidden or not     |
| location       | PFGeoPoint      | Object that stores the location of the post |
| createdAt      | DateTime        | unique id for the user post (default field) |
| updatedAt      | DateTime        | unique id for the user post (default field) |

**Comment**
| Property       | Type            | Description                                 |
| -------------- | --------------- | ------------------------------------------- |
| objectId       | String          | unique id for the comment (default field)   |
| post           | Pointer to Post | post where the comment was done on          |
| author         | Pointer to User | comment author                              |
| text           | String          | comment text by author                      |
| hideUsername   | Boolean         | Should username be hidden or not            |
| hideProfilePic | Boolean         | Should profile picture be hidden or not     |
| createdAt      | DateTime        | unique id for the user post (default field) |
| updatedAt      | DateTime        | unique id for the user post (default field) |

### Networking
- Login/Sign up screen
    - (Read/GET) Get user data
    - (Create/POST) Create a new user
- Home/Timeline screen
    - (Read/GET) Get posts for timeline
    - (Create/POST) Create new like/dislike on post
    - (Delete) Delete like/dislike on post
- Create/Compose post screen
    - (Create/POST) Create new post
- Map screen
    - (Read/GET) Get posts for map
- Post Detail screen
    - (Create/POST) Create new like/dislike on post
    - (Create/POST) Create new comment on post
    - (Update/PUT) Edit own post
    - (Delete) Delete dislike/like on post
    - (Delete) Delete post
- Settings Screen
    - (Delete) Delete all likes, dislikes, posts, comments, or account
- Data Screen
    - (Read/GET) Get user's likes/dislikes/comments/posts
    - (Delete) Delete specific like/dislike/comment/post

## Difficult/Ambiguous Technical Problems
- Complex data models that implement relations in order for faster retrieval and deletion of data
    - User <-> Posts
    - User <-> Liked Posts
    - User <-> Disliked Posts
    - User <-> Comments
    - other examples can be found in Schema above...
- Privacy concern handling
    - Users can hide location, username, and profile picture on their posts and comments
    - They also have the option to change those decisions later on (except comments)
    - Users can delete all of their data (posts, likes, dislikes, comments, and account) through the Settings Screen
    - Users can delete specific data from Data Screen
- Filter and ranking features for posts
    - Only posts within a 5-mile radius are queried for timeline
    - When the map is refreshed, a rectangle based on the southwest and northeast coordinates of the map that the user sees is created to query posts only within that area
- Handling of edge cases with Like/Dislike feature
    - Changes made locally overwrite those currently stored in Parse DB if the post is not up to date
    - Example:
        - User likes a post from home page
        - Then, through maps, the user dislikes the same post by going to its details screen
        - Back in home page, the user then unlikes the same post again (which is not updated)
        - Result: the post locally will be disliked and will overwrite the previous choice that was stored in Parse. The most updated post will now be disliked too.
- Usage of CloudCode
    - Code for data deletion was migrated to Parse Server through CloudCode in JavaScript
        - No matter how many operations a CloudCode function performs, it will only consume one request
    - CloudJob was created and set up as a Cron Job in order to automatically delete old posts

## Future Improvements
### Query Limit
Parse used to contain a retrieval limit of 1000 objects per query. However, that has since been removed. Although it solves many problems, it creates ambiguity.
- No specific limit is stated for Parse Server, so it's impossible to know the limitations of Parse now

For now, the app will offset these heavy queries to CloudCode and assume that it will be able to complete them, no matter the size. For future improvement, it would be smart to look in-depth into Parse Server's limit by reaching out to its developers, or perhaps considering other powerful servers.

### Like/Dislike Check
One of the difficult/ambiguous technical problems is the handling of edge cases with Like/Dislike feature. As stated above, it's possible that the data of a post the user sees locally is no longer the most updated version of the post as in the Parse database.
- The current solution queries the updated post on the database, overwrites it with the local changes, and saves it.

For future improvent, a CloudCode function could be created and called to run the checks and return the correct, updated data of the post. The app will then only need to wait to update the data on the screen without worrying about the logic.

### Map Design
The use has the ability to see the location of posts on the map. The map allows the user to look freely on other areas outside of the 5-mile radius, instead of locking on the user's location.
- Currently, the user has to manually move through the map and click a refresh button to see the posts in the area.

For future improvement, the map could have an option to lock the view on the user's location and zoom closely. This would allow the user to see posts near them without needing to constantly adjust the map view.
