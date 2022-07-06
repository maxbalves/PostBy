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
@property (nonatomic, strong) NSNumber *commentCount;
@property (nonatomic, strong) NSNumber *likeCount;
@property (nonatomic, strong) NSNumber *dislikeCount;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;

+ (void) postWithText:(NSString *)text withLat:(NSNumber *)latitude withLong:(NSNumber *)longitude withCompletion:(PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
