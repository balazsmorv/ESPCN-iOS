//
//  OpenCVWrapper.m
//  ESPCN
//
//  Created by Balázs Morvay on 2023. 05. 29..
//

#import <opencv2/opencv2.h>
#import "OpenCVWrapper.h"
#import <Foundation/Foundation.h>
#import <opencv2/Imgproc.h>
#import <opencv2/imgcodecs/ios.h>


using namespace std;


@implementation OpenCVWrapper

+(UIImage *)rgb_to_ycrbc:(UIImage *)source {
    cv::Mat m;
    UIImageToMat(source, m);
    cv::Mat ycrbc(64, 64, CV_32F, cv::Scalar(0));
    cvtColor(m, ycrbc, cv::COLOR_RGB2YCrCb);
    return MatToUIImage(ycrbc);
}

+(UIImage *)uiimage_from_y:(UInt8*)y and_cr:(UInt8*)cr and_bc:(UInt8*)bc width:(int)w height:(int)h {
    
    int w_targ = w * 4;
    int h_targ = h * 4;
    
    cv::Mat Y(w_targ, h_targ, CV_8UC1);
    cv::Mat CR(w, h, CV_8UC1);
    cv::Mat CB(w, h, CV_8UC1);
    
    for(int i = 0; i < w_targ; i++) {
        for(int j = 0; j < h_targ; j++) {
            Y.at<UInt8>(i, j) = y[i*w_targ + j];
        }
    }
    for(int i = 0; i < w; i++) {
        for(int j = 0; j < h; j++) {
            CR.at<UInt8>(i, j) = cr[i*w + j];
        }
    }
    for(int i = 0; i < w; i++) {
        for(int j = 0; j < h; j++) {
            CB.at<UInt8>(i, j) = bc[i*w + j];
        }
    }
    
    cv::Mat CR_reshaped(w_targ, h_targ, CV_8UC1);
    cv::resize(CR, CR_reshaped, cv::Size(w_targ, h_targ), 0, 0, cv::INTER_CUBIC);
    
    cv::Mat CB_reshaped(w_targ, h_targ, CV_8UC1);
    cv::resize(CB, CB_reshaped, cv::Size(w_targ, h_targ), 0, 0, cv::INTER_CUBIC);
    
    // Iterate over the matrix and print the data
        
    vector<cv::Mat> channels {Y, CR_reshaped, CB_reshaped};
    cv::Mat merged(w_targ, h_targ, CV_8UC3);
    cv::merge(channels, merged);
    
    cv::Mat rgb_image({w_targ, h_targ, 3}, CV_8UC1, cv::Scalar(0));
    cvtColor(merged, rgb_image, cv::COLOR_YCrCb2RGB);
    
    return MatToUIImage(rgb_image);
}

@end
