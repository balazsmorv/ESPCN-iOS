//
//  OpenCVWrapper.h
//  ESPCN
//
//  Created by Balázs Morvay on 2023. 05. 29..
//

#ifndef OpenCVWrapper_h
#define OpenCVWrapper_h

#import <UIKit/UIKit.h>
#import <opencv2/opencv2.h>

@interface OpenCVWrapper : NSObject

+(UIImage *)rgb_to_ycrbc:(UIImage *)source;
+(UIImage *)uiimage_from_y:(UInt8*)y and_cr:(UInt8*)cr and_bc:(UInt8*)bc width:(int)w height:(int)h;

@end


#endif /* OpenCVWrapper_h */
