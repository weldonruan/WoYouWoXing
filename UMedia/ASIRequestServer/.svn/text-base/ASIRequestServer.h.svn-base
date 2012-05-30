//
//  ASIRequestServer.h
//  PhotoTogether
//
//  Created by zt on 11-7-12.
//  Copyright 2011年 Vanillatech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@protocol ASIRequestServerCallback;
@interface ASIRequestServer : NSObject<ASIHTTPRequestDelegate> {
    NSOperationQueue		* _operationQueue;
    NSMutableArray  *_callbackManager;
    SEL finishedAction;
	SEL failedAction;
    id  target;
}
+ (ASIRequestServer *)sharedASIRequestServer;

- (void)firstRecordRequest:(NSString *)url
                clientType:(NSString *)client_type
             systemVersion:(NSString *)client_system_version
                appVersion:(NSString *)app_version
                  deviceId:(NSString *)device_id
              device_model:(NSString *)device_model
                    target:(id)t
            finishedAction:(SEL)finishedSelector
              failedAction:(SEL)failedSelector;

- (void)photoOperationRecordRequest:(NSString *)url
                           deviceId:(NSString *)device_id
                         appVersion:(NSString *)app_version
                               data:(NSMutableDictionary *)data
                             target:(id)t
                     finishedAction:(SEL)finishedSelector
                       failedAction:(SEL)failedSelector;

- (void)updateDevicePushIdRequest:(NSString *)url
                         deviceId:(NSString *)device_id   
                           pushId:(NSString *)device_push_id;

- (void)userBehaviorRcordRequest:(NSString *)url
                        deviceId:(NSString *)device_id
                 startAndStopArr:(NSMutableDictionary *)start_stop
                          target:(id)t
                  finishedAction:(SEL)finishedSelector
                    failedAction:(SEL)failedSelector;

- (void)checkApplicationVersionWithCallback:(id)callback;


- (void)postLastException:(NSString *)exDescription;
- (void)postFirstThemeSelection:(NSString *)themeName;
- (void)postFuntionSelection:(NSString *)functionName;

//Get RecommondList Method:
- (void)getRecommondListWithTarget:(id)t
                    finishedAction:(SEL)finishedSelector
                      failedAction:(SEL)failedSelector; 

- (void)writeImageToFileWithURL:(NSString *)imageURL
                   attachmentId:(NSString *)attId
                        callback:(id<ASIRequestServerCallback>)cb;
@end

@protocol ASIRequestServerCallback <NSObject>

- (void) didFinishLoad:(id)sender;


@end
