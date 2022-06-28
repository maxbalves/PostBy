# PostBy (remix of Yik Yak)

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
App allows users to see and create posts for their timeline. Each timeline will display the user's posts and posts from other users within a certain mile radius (around 1-5 miles). App will allow users to open a map and see where exactly each post originated from.

### App Evaluation
- **Category:** Social Networking
- **Mobile:** Mobile is important because the app will be a social networking platform that users can quickly check and engage on. The mobile phone's location will be important for the app's features.
- **Story:** Users will be able to see posts from users around the area, which can create more community, allow for meetups, and create local entertainment.
- **Market:** Any individual with a mobile phone is able to benefit from the app for their own entertainment.
- **Habit:** The app can be used daily in order to see new messages and the posts around the user. It could create a habit of checking/creating posts everyday.
- **Scope:** On the most basic level, the app will demonstrate a timeline for creating and viewing posts in the area and showing pins of where the posts where made. As stretch goals, the app could the ability to change locations and see posts from other places, and group pins together as you zoom out of a zone.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* Users can see posts within specific mile radius
* Users can create posts
* Users can access a map that shows all posts' locations
    * As user zooms out, pins are grouped for better display
* Users can login and register accounts

**Optional Nice-to-have Stories**

* Users can like or dislike posts
* Users can comment on posts
* Users can switch between New and Trending tab
    * Trending tab shows posts ordered in descending order of likes
    * New tab shows posts in chronological order
* Old posts are automatically removed from the database.
* Clicking on a post in the map screen, brings you to detail screen of that post

### 2. Screen Archetypes

* Login screen
   * User can login
* Sign up screen
   * User can sign up
* Home/Timeline screen
    * Users can see posts within specific mile radius
    * Users can like or dislike posts
    * Users can switch between New and Trending tab
        * This would require 2 different views for Home
        * Or, reload the tableView after sorting array of posts
* Create/Compose post screen
    * Users can create posts
* Map screen
    * Users can access a map that shows all posts’ locations
    * As user zooms out, pins are grouped for better display
* Post Detail screen
    * Users can like or dislike post
    * Users can comment on posts



### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Home Feed
* Map Screen
* Create Screen

**Flow Navigation** (Screen to Screen)

* Login screen
   => Home Feed
   => Sign up screen
* Sign Up Screen
   => Home Feed
* Home/Timeline screen
   => Post Detail Screen
* Create/Compose post screen
   => Home Feed (after creating post)
* Map screen
   => Post Detail Screen (on clicked post) (extra)
* Post Detail Screen
   => Home Screen (go back)

## Wireframes
[Add picture of your hand sketched wireframes in this section]
<img src="https://github.com/maxbalves/PostBy/blob/main/HandWireframe.png?raw=true" width=600>

### [BONUS] Digital Wireframes & Mockups

### [BONUS] Interactive Prototype

## Schema 
[This section will be completed in Unit 9]
### Models
[Add table of models]
### Networking
- [Add list of network requests by screen ]
- [Create basic snippets for each Parse network request]
- [OPTIONAL: List endpoints if using existing API such as Yelp]
