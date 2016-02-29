//
//  InstagramAssetsPicker.h
//
//  Created by Ross Martin on 2/25/16.
//
//

#import <Cordova/CDV.h>


@interface InstagramAssetsPicker : CDVPlugin {
}

@property (copy) NSString* callbackId;

- (void)getMedia:(CDVInvokedUrlCommand*)command;
- (void)cropAsset:(CDVInvokedUrlCommand*)command;
+(NSString*)getUUID;

@end
