//
//  Post.h
//  PostBy
//
//  Created by Max Bagatini Alves on 7/5/22.
//

@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface Post : PFObject <PFSubclassing>

@property (nonatomic, strong) PFUser *author;
@property (nonatomic, strong) NSString *postText;
@property (nonatomic, strong) PFGeoPoint *location;
@property (nonatomic) BOOL hideLocation;
@property (nonatomic) BOOL hideUsername;
@property (nonatomic) BOOL hideProfilePic;
@property (nonatomic, strong) NSNumber *likeCount;
@property (nonatomic, strong) NSNumber *dislikeCount;

+ (void) postWithText:(NSString *)text withLocation:(PFGeoPoint *)location hideLocation:(BOOL)hideLocation hideUsername:(BOOL)hideUsername hideProfilePic:(BOOL)hideProfilePic withCompletion:(PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
