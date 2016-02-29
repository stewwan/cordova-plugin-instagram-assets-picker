//
//  InstagramAssetsPicker.m
//
//  Created by Ross Martin on 2/25/16.
//
//

#import "InstagramAssetsPicker.h"
#import "IGAssetsPicker.h"
#import "IGCropView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface InstagramAssetsPicker ()<IGAssetsPickerDelegate>

@end

@implementation InstagramAssetsPicker

@synthesize callbackId;

/**
 * getMedia
 *
 * Show a UI media picker similar to Instagram
 *
 * ARGUMENTS
 * =========
 * type               - (NSString) type of media to choose (video, photo, or all)
 * cropAfterSelect    - (BOOL) determine whether to perfrom crop right away
 *
 * RESPONSE
 * ========
 *
 * filePath           - (NSString) path to the chosen media file
 * rect               - (CGRect) rect object with data needed for cropping at a later time
 *
 * @param CDVInvokedUrlCommand command
 * @return void
 */
- (void) getMedia:(CDVInvokedUrlCommand*)command
{
    NSLog(@"getMedia");
    self.callbackId = command.callbackId;

    NSDictionary* options = [command.arguments objectAtIndex:0];

    if ([options isKindOfClass:[NSNull class]]) {
        options = [NSDictionary dictionary];
    }

    NSString *mediaType = ([options objectForKey:@"type"]) ? [options objectForKey:@"type"] : @"all";
    BOOL cropAfterSelect = ([options objectForKey:@"cropAfterSelect"]) ? [[options objectForKey:@"cropAfterSelect"] boolValue] : NO;

    ALAssetsFilter *filterType;
    if ([mediaType isEqualToString:@"photo"]) {
        filterType = [ALAssetsFilter allPhotos];
    } else if ([mediaType isEqualToString:@"video"]) {
        filterType = [ALAssetsFilter allVideos];
    } else {
        filterType = [ALAssetsFilter allAssets];
    }

    IGAssetsPickerViewController *picker = [[IGAssetsPickerViewController alloc] init];
    picker.delegate = self;
    picker.alAssetFilter = filterType;
    picker.cropAfterSelect = cropAfterSelect;
    [self.viewController presentViewController:picker animated:YES completion:NULL];

}

/**
 * cropAsset
 *
 * Crop a media asset (photo or video)
 *
 * ARGUMENTS
 * =========
 * filePath           - (NSString) path to the ALAsset
 * rect               - (CGRect) rect object with data needed for cropping
 *
 * RESPONSE
 * ========
 *
 * filePath           - (NSString) path to the chosen media file
 *
 * @param CDVInvokedUrlCommand command
 * @return void
 */
- (void) cropAsset:(CDVInvokedUrlCommand*)command
{
    NSLog(@"cropAsset");

    NSDictionary* options = [command.arguments objectAtIndex:0];

    if ([options isKindOfClass:[NSNull class]]) {
        options = [NSDictionary dictionary];
    }

    NSString *filePath = [options objectForKey:@"filePath"];
    NSURL *fileURL = [self getURLFromFilePath:filePath];
    NSDictionary *rectData = [options objectForKey:@"rect"];
    CGRect rect;
    CGRectMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)(rectData), &rect);

    NSString *outputName = [InstagramAssetsPicker getUUID];
    __block NSString *outputPath;
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];

    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];

    [self.commandDelegate runInBackground:^{
        [library assetForURL:fileURL resultBlock:^(ALAsset *asset) {
            if (asset) {
                id croppedAsset = [IGCropView cropAlAsset:asset withRegion: rect];

                if ([croppedAsset isKindOfClass:[UIImage class]]) {
                    NSLog(@"cropped a photo");
                    UIImage *photo = (UIImage *)croppedAsset;
                    outputPath = [cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", outputName, @"jpg"]];
                    [UIImageJPEGRepresentation(photo, 1.0) writeToFile:outputPath atomically:YES];
                } else if ([croppedAsset isKindOfClass:[NSURL class]]) {
                    NSLog(@"cropped a video");
                    outputPath = [(NSURL *)croppedAsset absoluteString];
                }

                [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:outputPath] callbackId:command.callbackId];
            } else {
                // TODO: should I handle this if the input file is not an ALAsset?
                [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"input file is not an ALAsset"] callbackId:command.callbackId];
            }
        } failureBlock:^(NSError *error) {
            NSLog(@"failed to use ALAssetsLibrary");
        }];
    }];
}

#pragma mark - IGAssetsPickerDelegate

- (void)IGAssetsPickerFinishCroppingToAsset:(id)asset
{
    NSString *outputName = [InstagramAssetsPicker getUUID];
    NSString *outputPath;
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];

    if ([asset isKindOfClass:[UIImage class]]) { // photo
        NSLog(@"chose a photo");
        UIImage *photo = (UIImage *)asset;
        outputPath = [cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", outputName, @"jpg"]];
        [UIImageJPEGRepresentation(photo, 1.0) writeToFile:outputPath atomically:YES];
    } else if ([asset isKindOfClass:[NSURL class]]) { // video
        NSLog(@"chose a video");
        outputPath = [(NSURL*)asset absoluteString];
    }

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:outputPath forKey:@"filePath"];

    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict] callbackId:self.callbackId];
}

- (void)IGAssetsPickerGetCropRegion:(CGRect)rect withAlAsset:(id)asset
{
    NSLog(@"IGAssetsPickerGetCropRegion");

    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary: @{
       @"rect" : CFBridgingRelease(CGRectCreateDictionaryRepresentation(rect))
    }];

    ALAssetRepresentation *rep = [asset defaultRepresentation];

    if([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) // photo
    {
        CGImageRef resolutionRef = [rep fullResolutionImage];
        UIImage *photo = [UIImage imageWithCGImage:resolutionRef scale:1.0f orientation:(UIImageOrientation)rep.orientation];

        NSString *outputName = [InstagramAssetsPicker getUUID];
        NSString *outputPath;
        NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];

        outputPath = [cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", outputName, @"jpg"]];
        dict[@"filePath"] = outputPath;
        [UIImageJPEGRepresentation(photo, 1.0) writeToFile:outputPath atomically:YES];
    }
    else if([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) // video
    {
        dict[@"filePath"] = rep.url.absoluteString;
    }

    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict] callbackId:self.callbackId];
}

- (NSURL*)getURLFromFilePath:(NSString*)filePath
{
    if ([filePath containsString:@"assets-library://"]) {
        return [NSURL URLWithString:[filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    } else if ([filePath containsString:@"file://"]) {
        return [NSURL URLWithString:[filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }

    return [NSURL fileURLWithPath:[filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

+ (NSString *)getUUID
{
    CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
    NSString * uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
    CFRelease(newUniqueId);

    return uuidString;
}

@end
