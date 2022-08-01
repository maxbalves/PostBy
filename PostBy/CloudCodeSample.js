// Delete user's likes
Parse.Cloud.define("deleteLikes", async (request) => {
  // delete likes from user relation
  const currentUser = request.user;
  const likesRelation = currentUser.relation(request.params.likesRelationName);
  const likesQuery = likesRelation.query();
  const queryLimit = await likesQuery.count();
  likesQuery.limit(queryLimit);
  const likesResult = await likesQuery.find();
  for (let i = 0; i < likesResult.length; i++) {
    const post = likesResult[i];
    // unlike the post
    post.increment("likeCount", -1);
    likesRelation.remove(post);
    //remove relation from post
    const postLikesRelation = post.relation(request.params.likesRelationName);
    postLikesRelation.remove(currentUser);
    post.save();
  }
  // null means we don't want to save any other object
  await currentUser.save(null, {useMasterKey : true});
});

// Delete user's dislikes
Parse.Cloud.define("deleteDislikes", async (request) => {
  // delete dislikes from user relation
  const currentUser = request.user;
  const dislikesRelation = currentUser.relation(request.params.dislikesRelationName);
  const dislikesQuery = dislikesRelation.query();
  const queryLimit = await dislikesQuery.count();
  dislikesQuery.limit(queryLimit);
  const dislikesResult = await dislikesQuery.find();
  for (let i = 0; i < dislikesResult.length; i++) {
    const post = dislikesResult[i];
    // unlike the post
    post.increment("dislikeCount", -1);
    dislikesRelation.remove(post);
    //remove relation from post
    const postDislikesRelation = post.relation(request.params.dislikesRelationName);
    postDislikesRelation.remove(currentUser);
    post.save();
  }
  // null means we don't want to save any other object
  await currentUser.save(null, {useMasterKey : true});
});

// Delete specific post
Parse.Cloud.define("deletePost", async (request) => {
  const query = new Parse.Query(request.params.postClassName);
  query.equalTo("objectId", request.params.postId);
  
  const post = await query.first();
  const author = post.get(request.params.authorField);

  // Delete comments
  const commentsRelation = post.relation(request.params.commentsRelationName);
  const commentsQuery = commentsRelation.query();
  const commentsQueryLimit = await commentsQuery.count();
  commentsQuery.limit(commentsQueryLimit);
  const commentsResult = await commentsQuery.find();
  for (let i = 0; i < commentsResult.length; i++) {
    const comment = commentsResult[i];
    request.params["commentId"] = comment.id;
    Parse.Cloud.run("deleteComment", request.params);
  }
  
  // Delete author's relation to post
  const userRelation = author.relation(request.params.postsRelationName);
  userRelation.remove(post);
  author.save(null, {useMasterKey : true});
  
  // Delete likes relations
  const postLikesRelation = post.relation(request.params.likesRelationName);
  const likesQuery = postLikesRelation.query();
  const likesQueryLimit = await likesQuery.count();
  likesQuery.limit(likesQueryLimit);
  const likesResult = await likesQuery.find();
  for (const user of likesResult) {
    const userLikes = user.relation(request.params.likesRelationName);
    userLikes.remove(post);
    user.save(null, {useMasterKey : true});
  }
  
  // Delete dislikes relations
  const postDislikesRelation = post.relation(request.params.dislikesRelationName);
  const dislikesQuery = postDislikesRelation.query();
  const dislikesQueryLimit = await dislikesQuery.count();
  dislikesQuery.limit(dislikesQueryLimit);
  const dislikesResult = await dislikesQuery.find();
  for (const user of dislikesResult) {
    const userDislikes = user.relation(request.params.dislikesRelationName);
    userDislikes.remove(post);
    user.save(null, {useMasterKey : true});
  }
  
  // Delete post
  post.destroy();
});

// Delete the user's posts & comments under it
Parse.Cloud.define("deletePosts", async (request) => {
  const currentUser = request.user;
  const postsRelation = currentUser.relation(request.params.postsRelationName);
  const postsQuery = postsRelation.query();
  const queryLimit = await postsQuery.count();
  postsQuery.limit(queryLimit);
  const postsResult = await postsQuery.find();
  for (let i = 0; i < postsResult.length; i++) {
    const post = postsResult[i];
    request.params["postId"] = post.id;
    Parse.Cloud.run("deletePost", request.params, {sessionToken : currentUser.getSessionToken()});
  }
});

// Delete specific comment
Parse.Cloud.define("deleteComment", async (request) => {
  const query = new Parse.Query(request.params.commentClassName);
  query.equalTo("objectId", request.params.commentId);
  
  const comment = await query.first();
  const user = comment.get(request.params.authorField);
  const post = comment.get(request.params.postField);
  
  // Delete comment from user's COMMENTS_RELATION
  const userRelation = user.relation(request.params.commentsRelationName);
  userRelation.remove(comment);
  user.save(null, {useMasterKey : true});
  
  // Delete comment from post's COMMENTS_RELATION
  const postRelation = post.relation(request.params.commentsRelationName);
  postRelation.remove(comment);
  post.save();
  
  comment.destroy();
});

// Delete user's comments
Parse.Cloud.define("deleteComments", async (request) => {
  const currentUser = request.user;
  const commentsRelation = currentUser.relation(request.params.commentsRelationName);
  const commentsQuery = commentsRelation.query();
  const queryLimit = await commentsQuery.count();
  commentsQuery.limit(queryLimit);
  const commentsResult = await commentsQuery.find();
  for (let i = 0; i < commentsResult.length; i++) {
    const comment = commentsResult[i];
    request.params["commentId"] = comment.id;
    Parse.Cloud.run("deleteComment", request.params, {sessionToken : currentUser.getSessionToken()});
  }
});

// Delete all of user's data
Parse.Cloud.define("deleteAccount", async (request) => {
  const user = request.user;
  
  await Parse.Cloud.run("deletePosts", request.params, {sessionToken : user.getSessionToken()});
  await Parse.Cloud.run("deleteLikes", request.params, {sessionToken : user.getSessionToken()});
  await Parse.Cloud.run("deleteDislikes", request.params, {sessionToken : user.getSessionToken()});
  await Parse.Cloud.run("deleteComments", request.params, {sessionToken : user.getSessionToken()});
  
  // delete account
  await user.destroy({useMasterKey : true});
});


// Delete Old Posts - Cron Job
Parse.Cloud.job("removeOldPosts", async (request) => {
  const date = new Date();
  const timeNow = date.getTime();
  // Posts updatedAt older than: 2 days
  // 2 (days) * 24 (hours) * 60 (minutes) * 60 (seconds) * 1000 (milliseconds)
  const intervalOfTime = 2 * 24 * 60 * 60 * 1000;
  const timeThen = timeNow - intervalOfTime;
  
  // Limit date
  const queryDate = new Date();
  queryDate.setTime(timeThen);
  
  // Query object
  const query = new Parse.Query(request.params.postClassName);
  
  // Query posts last modified more than 1 minute ago
  query.lessThanOrEqualTo("updatedAt", queryDate);
  
  // Get query limit
  const queryLimit = await query.count();
  query.limit(queryLimit);
  
  const results = await query.find({useMasterKey : true});
  
  // Loop through and delete posts + their comments
  for (const post of results) {
    request.params["postId"] = post.id;
    Parse.Cloud.run("deletePost", request.params);
  }
  
  return("Successfully retrieved " + results.length + " old posts.");
});
