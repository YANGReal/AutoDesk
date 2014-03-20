#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>


@interface PPSSignatureView : GLKView

@property (assign, nonatomic) BOOL hasSignature;
@property (strong, nonatomic) UIImage *signatureImage;
@property (assign , nonatomic,readwrite) GLKVector3 color;
@property (assign , nonatomic) int fontWidth;
- (void)erase;

@end
