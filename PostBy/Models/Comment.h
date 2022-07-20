//
//  Comment.h
//  PostBy
//
//  Created by Max Bagatini Alves on 7/20/22.
//

// Frameworks
@import Parse;

// Models
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN

@interface Comment : PFObject <PFSubclassing>

@property (nonatomic, strong) Post *post;
@property (nonatomic, strong) PFUser *author;
@property (nonatomic, strong) NSString *commentText;
@property (nonatomic) BOOL hideUsername;
@property (nonatomic) BOOL hideProfilePic;

+ (void)commentWithText:(NSString *)text onPost:(Post *)post hideUsername:(BOOL)hideUsername hideProfilePic:(BOOL)hideProfilePic withCompletion:(PFBooleanResultBlock)completion;

@end

NS_ASSUME_NONNULL_END
