// Delete the user's posts & comments under it
Parse.Cloud.define("deletePosts", async (request) => {
  let currentUser = request.user;
  let postsRelation = currentUser.relation(request.params.postsRelationName);
  let postsQuery = postsRelation.query();
  const postsResult = await postsQuery.find();
  for (let i = 0; i < postsResult.length; i++) {
    let commentsRelation = postsResult[i].relation(request.params.commentsRelationName);
    let commentsResult = await commentsRelation.query().find();
    for (let j = 0; j < commentsResult.length; j++) {
      commentsResult[j].destroy();
    }
    postsResult[i].destroy();
  }
});

// Delete user's likes
Parse.Cloud.define("deleteLikes", async (request) => {
  // delete likes from user relation
  let currentUser = request.user;
  let likesRelation = currentUser.relation(request.params.likesRelationName);
  let likesQuery = likesRelation.query();
  const likesResult = await likesQuery.find();
  for (let i = 0; i < likesResult.length; i++) {
    let post = likesResult[i];
    // unlike the post
    post.increment("likeCount", -1);
    likesRelation.remove(post);
    //remove relation from post
    let postLikesRelation = post.relation(request.params.likesRelationName);
    postLikesRelation.remove(currentUser);
    await post.save();
  }
  // null means we don't want to save any other object
  await currentUser.save(null, {useMasterKey : true});
});

// Delete user's dislikes
Parse.Cloud.define("deleteDislikes", async (request) => {
  // delete dislikes from user relation
  let currentUser = request.user;
  let dislikesRelation = currentUser.relation(request.params.dislikesRelationName);
  let dislikesQuery = dislikesRelation.query();
  const dislikesResult = await dislikesQuery.find();
  for (let i = 0; i < dislikesResult.length; i++) {
    let post = dislikesResult[i];
    // unlike the post
    post.increment("dislikeCount", -1);
    dislikesRelation.remove(post);
    //remove relation from post
    let postDislikesRelation = post.relation(request.params.dislikesRelationName);
    postDislikesRelation.remove(currentUser);
    await post.save();
  }
  // null means we don't want to save any other object
  await currentUser.save(null, {useMasterKey : true});
});

// Delete user's comments
Parse.Cloud.define("deleteComments", async (request) => {
  let currentUser = request.user;
  let commentsRelation = currentUser.relation(request.params.commentsRelationName);
  let commentsQuery = commentsRelation.query();
  const commentsResult = await commentsQuery.find();
  for (let i = 0; i < commentsResult.length; i++) {
    commentsResult[i].destroy();
  }
});

// Delete all of user's data
Parse.Cloud.define("deleteAccount", async (request) => {
  let user = request.user;
  
  await Parse.Cloud.run("deletePosts", request.params, {sessionToken : user.getSessionToken()});
  await Parse.Cloud.run("deleteLikes", request.params, {sessionToken : user.getSessionToken()});
  await Parse.Cloud.run("deleteDislikes", request.params, {sessionToken : user.getSessionToken()});
  await Parse.Cloud.run("deleteComments", request.params, {sessionToken : user.getSessionToken()});
  
  // delete account
  await user.destroy({useMasterKey : true});
});
