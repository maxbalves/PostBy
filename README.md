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
    * Users can switch between Newest or Trending sort
* Create/Compose post screen
    * Users can create posts
    * Users can choose privacy settings
* Map screen
    * Users can access a map that shows all posts’ locations
    * As user zooms out, pins are grouped for better display
    * Clicking on a link displays a post's details
    * Users can manage the number of posts displayed at once on the map
* Post Detail screen
    * Users can like or dislike post
    * Users can comment on posts
    * Users can edit / delete post if its their own
    * Users can click on info icon to see where post was created
* Settings Screen
    * Users can delete account
    * Users can set a profile picture
    * Users can set persistant privacy settings



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

## Wireframes
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
    - (Create/POST) Create new dislike on post
    - (Create/POST) Create new comment on post
    - (Delete) Delete like/dislike on post
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

## Difficult/Ambiguous Technical Problems
- Complex data models that implement relations in order for faster retrieval and deletion of data
    - User <-> Posts
    - User <-> Liked Posts
    - User <-> Disliked Posts
    - User <-> Comments
    - other examples can be found in Schema above...
- Privacy concern handling
    - Users can hide location, username, and profile picture on their posts
    - They also have the option to change those decisions later on
    - Users can delete all of their data (posts, likes, dislikes, comments, and account) through the settings page
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
