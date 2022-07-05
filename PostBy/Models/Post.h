//
//  Post.h
//  PostBy
//
//  Created by Max Bagatini Alves on 7/5/22.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Post : PFObject <PFSubclassing>

@property (nonatomic, strong) PFUser *author;
@property (nonatomic, strong) NSString *postText;
@property (nonatomic, strong) NSNumber *commentCount;
@property (nonatomic, strong) NSNumber *likeCount;
@property (nonatomic, strong) NSNumber *dislikeCount;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;

// TODO: Implement privacy options
// i.g. (BOOL) showLocation, (BOOL) showUsername, (BOOL) showProfilePicture

+ (void) postWithText:(NSString *)text withCompletion:(PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
