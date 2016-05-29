//
//  IGCropView.h
//  InstagramAssetsPicker
//
//  Created by JG on 2/3/15.
//  Copyright (c) 2015 JG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

@interface IGCropView : UIScrollView;
@property (nonatomic, strong) ALAsset * alAsset;
@property (nonatomic, strong) PHAsset * phAsset;

- (void)cropAsset:(void(^)(id))completeBlock;

- (void)getCropRegion:(void(^)(CGRect))completeBlock;

- (void)stopPlayingIfNecessary;

- (void)cropVideo:(PHAsset *)asset withRegion:(CGRect)rect onComplete:(void(^)(NSURL *))completion;

// for late crop
+ (void)cropPhAsset:(PHAsset *)asset withRegion:(CGRect)rect onComplete:(void(^)(id))completion;

@end
