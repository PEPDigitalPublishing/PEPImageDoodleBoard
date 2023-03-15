//
//  PEPCutImageManager.h
//  PEPImageDoodleBoard
//
//  Created by ran cui on 2021/7/5.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface PEPCutImageManager : NSObject

+ (instancetype)shareManager;

/**指定区域截图*/
- (UIImage *)cutImageWithRect:(CGRect)rect andTargetImage:(UIImage *)targetImage andViewSize:(CGSize)size andOutputWidth:(CGFloat)outputWidth;

@end
