//
//  ASIRequestServer.m
//  PhotoTogether
//
//  Created by zt on 11-7-12.
//  Copyright 2011年 Vanillatech. All rights reserved.
//

#import "ASIRequestServer.h"
#import "ASIFormDataRequest.h"
#import "PathManager.h"
#import "JSONKit.h"
#import "UIDevice+Machine.h"
static ASIRequestServer *sharedASIRequestServer = nil;

@interface ASIRequestServer(private)

-(void)firstRecordDidFinished:(ASIFormDataRequest *)request;
-(void)firstRecordDidFailed:(ASIFormDataRequest *)request;
-(void)operationRecordDidFinished:(ASIFormDataRequest *)request;
-(void)operationRecordDidFailed:(ASIFormDataRequest *)request;
-(void)updateDevicePushIdDidFinished:(ASIFormDataRequest *)request;
-(void)updateDevicePushIdDidFailed:(ASIFormDataRequest *)request;
-(void)userBehaviorRcordDidFinished:(ASIFormDataRequest *)request;
-(void)userBehaviorRcordDidFailed:(ASIFormDataRequest *)request;
@end

@implementation ASIRequestServer
 
+ (ASIRequestServer *)sharedASIRequestServer
{ 
    if (sharedASIRequestServer == nil) {
        sharedASIRequestServer = [[ASIRequestServer alloc] init];
    }
    return sharedASIRequestServer;
}

- (id) init
{
	self = [super init];
	if (self != nil) {
        _operationQueue = [[NSOperationQueue alloc] init];
        [_operationQueue setMaxConcurrentOperationCount:1];
        _callbackManager = [[NSMutableArray alloc] initWithCapacity:0];
        finishedAction = nil;
        failedAction = nil;
        target = nil;
	}
	
	return self;
}

- (void) dealloc
{
    finishedAction = nil;
    failedAction = nil;
    target = nil;
    SAFE_RELEASE(_callbackManager);
    SAFE_RELEASE(_operationQueue);
	[super dealloc];
}

#pragma -
#pragma firstRecordRequest method
- (void)firstRecordRequest:(NSString *)url
                clientType:(NSString *)client_type
             systemVersion:(NSString *)client_system_version
                appVersion:(NSString *)app_version
                  deviceId:(NSString *)device_id
              device_model:(NSString *)device_model
                    target:(id)t
            finishedAction:(SEL)finishedSelector
              failedAction:(SEL)failedSelector
{
    DBG(@"clientType = %@ systemVersion = %@ appVersion = %@ deviceId = %@", client_type, client_system_version, app_version, device_id);
    finishedAction = finishedSelector;
    failedAction = failedSelector;
    target = t;
    NSURL *tempUrl = [[NSURL URLWithString:url] retain];
    ASIFormDataRequest *formDataRequest = [ASIFormDataRequest requestWithURL:tempUrl];
    [tempUrl release];
    [formDataRequest addPostValue:client_type forKey:@"client_type"];
    [formDataRequest addPostValue:client_system_version forKey:@"client_system_version"];
    [formDataRequest addPostValue:app_version forKey:@"app_version"];
    [formDataRequest addPostValue:device_id forKey:@"device_id"];
    [formDataRequest addPostValue:device_model forKey:@"device_model"];
    [formDataRequest setDelegate:self];
    [formDataRequest setDidFinishSelector:@selector(firstRecordDidFinished:)];
    [formDataRequest setDidFailSelector:@selector(firstRecordDidFailed:)];
    [_operationQueue addOperation:formDataRequest]; 
}
-(void)firstRecordDidFinished:(ASIFormDataRequest *)request
{
    DBG(@"first_record_responseString = %@",[request responseString]);
    if (target && finishedAction) {
        [target performSelector:finishedAction withObject:[[request responseString] objectFromJSONString]];

    }
    
}
-(void)firstRecordDidFailed:(ASIFormDataRequest *)request
{
    DBG(@"error = %@", [request error]);
    if (target && failedAction) {
        [target performSelector:failedAction withObject:[[request responseString] objectFromJSONString]];
    }
}

#pragma -
#pragma photoOperationRecordRequest method
- (void)photoOperationRecordRequest:(NSString *)url
                           deviceId:(NSString *)device_id
                         appVersion:(NSString *)app_version
                               data:(NSMutableDictionary *)data
                             target:(id)t
                     finishedAction:(SEL)finishedSelector
                       failedAction:(SEL)failedSelector
{
    finishedAction = finishedSelector;
    failedAction = failedSelector;
    target = t;
    
    NSURL *tempUrl = [[NSURL URLWithString:url] retain];
    ASIFormDataRequest *formDataRequest = [ASIFormDataRequest requestWithURL:tempUrl];
    [formDataRequest addPostValue:@"iphone" forKey:@"client_type"];
    [tempUrl release];
    [formDataRequest addPostValue:device_id forKey:@"device_id"];
    [formDataRequest addPostValue:app_version forKey:@"app_version"];    
    for (NSString *key in [data allKeys]) {
        [formDataRequest addPostValue:[data objectForKey:key] forKey:key];
        DBG(@"%@ ---- %@",[data objectForKey:key], key);
    }
    [formDataRequest setDelegate:self];
    [formDataRequest setDidFinishSelector:@selector(operationRecordDidFinished:)];
    [formDataRequest setDidFailSelector:@selector(operationRecordDidFailed:)];
    [_operationQueue addOperation:formDataRequest];
}
-(void)operationRecordDidFinished:(ASIFormDataRequest *)request 
{
    DBG(@"operation_record_responseString = %@", [request responseString]); 
    if (target && finishedAction) {
        [target performSelector:finishedAction withObject:[[request responseString] objectFromJSONString]];
    }

}
-(void)operationRecordDidFailed:(ASIFormDataRequest *)request 
{
    DBG(@"error = %@", [request error]);
    //[target performSelector:failedAction withObject:[[request responseString] objectFromJSONString]];
}

#pragma -
#pragma updateDevicePushIdRequest method
- (void)updateDevicePushIdRequest:(NSString *)url
                         deviceId:(NSString *)device_id   
                           pushId:(NSString *)device_push_id
{
    NSURL *tempUrl = [[NSURL URLWithString:url] retain];
    ASIFormDataRequest *formDataRequest = [ASIFormDataRequest requestWithURL:tempUrl];
    [tempUrl release];
    [formDataRequest addPostValue:device_id forKey:@"device_id"];
    [formDataRequest addPostValue:device_push_id forKey:@"device_push_id"];
    [formDataRequest setDelegate:self];
    [formDataRequest setDidFinishSelector:@selector(updateDevicePushIdDidFinished:)];
    [formDataRequest setDidFailSelector:@selector(updateDevicePushIdDidFailed:)];
    [_operationQueue addOperation:formDataRequest];
}

-(void)updateDevicePushIdDidFinished:(ASIFormDataRequest *)request
{
    DBG(@"update_record_responseString = %@", [request responseString]); 
    if ([[request responseString] isEqualToString:@"{\"error_code\":0,\"error\":\"\"}"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:STOREDKEY_APNS_REGISTERED];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(void)updateDevicePushIdDidFailed:(ASIFormDataRequest *)request
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:STOREDKEY_APNS_REGISTERED];
    [[NSUserDefaults standardUserDefaults] synchronize];
    DBG(@"error = %@", [request error]);
}


#pragma mark - userBehaviorRcordRequest method
- (void)userBehaviorRcordRequest:(NSString *)url
                        deviceId:(NSString *)device_id
                 startAndStopArr:(NSMutableDictionary *)start_stop
                          target:(id)t
                  finishedAction:(SEL)finishedSelector
                    failedAction:(SEL)failedSelector;
{
    finishedAction = finishedSelector;
    failedAction = failedSelector;
    target = t;
    
    NSURL *tempUrl = [[NSURL URLWithString:url] retain];
    ASIFormDataRequest *formDataRequest = [ASIFormDataRequest requestWithURL:tempUrl];
    [tempUrl release];
    [formDataRequest addPostValue:device_id forKey:@"device_id"];
    for (NSString *key in [start_stop allKeys]) {
        [formDataRequest addPostValue:[start_stop objectForKey:key] forKey:key];
    }
    [formDataRequest setDelegate:self];
    [formDataRequest setDidFinishSelector:@selector(userBehaviorRcordDidFinished:)];
    [formDataRequest setDidFailSelector:@selector(userBehaviorRcordDidFailed:)];
    [_operationQueue addOperation:formDataRequest];
}

-(void)userBehaviorRcordDidFinished:(ASIFormDataRequest *)request
{
    DBG(@"userBehavior_record_responseString = %@", [(NSDictionary *)[[request responseString] objectFromJSONString] objectForKey:@"error"]); 
    if (target && finishedAction) {
        [target performSelector:finishedAction withObject:[[request responseString] objectFromJSONString]];
    }
}
-(void)userBehaviorRcordDidFailed:(ASIFormDataRequest *)request
{
    DBG(@"error = %@", [request error]);
    if (target && failedAction) {
        [target performSelector:failedAction withObject:[[request responseString] objectFromJSONString]];
    }
}

- (void)checkApplicationVersionWithCallback:(id)callback
{
    [_callbackManager addObject:callback];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:CHECKVERSIONCODE_URL]];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(requestComplete:)];
    [request setDidFailSelector:@selector(requestFailed:)];
    [_operationQueue addOperation:request];
}

- (void)postLastException:(NSString *)exDescription
{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:CRASHLOG_URL]];
    [request addPostValue:@"iphone" forKey:@"client_type"];
    [request addPostValue:[[UIDevice currentDevice] machine] forKey:@"device_model"];
    [request addPostValue:[NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]] forKey:@"crach_time"];
    [request addPostValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"app_version"];
    [request addPostValue:[[UIDevice currentDevice] systemVersion] forKey:@"client_system_version"];
    [request addPostValue:exDescription forKey:@"info"];
    [_operationQueue addOperation:request];
}

- (void)postFirstThemeSelection:(NSString *)themeName
{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:THEMESELECTION_URL]];
    [request addPostValue:@"iphone" forKey:@"client_type"];
    [request addPostValue:themeName forKey:@"name"];
    [request addPostValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"app_version"];
    [_operationQueue addOperation:request];
}
- (void)postFuntionSelection:(NSString *)functionName
{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:FUNCTIONSELECTION_URL]];
    [request addPostValue:@"iphone" forKey:@"client_type"];
    [request addPostValue:functionName forKey:@"name"];
    [request addPostValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"app_version"];
    [_operationQueue addOperation:request];        
}

- (void)requestDidFailed:(ASIFormDataRequest *)request
{
    DBG(@"ASIFormDataRequest error = %@", [request error]);
}
- (void)requestDidFinished:(ASIFormDataRequest *)request
{
    DBG(@"ASIFormDataRequest finished = %@", [request responseString]);
}

//Get RecommondList Mthod:
- (void)getRecommondListWithTarget:(id)t
                    finishedAction:(SEL)finishedSelector
                      failedAction:(SEL)failedSelector
{
    finishedAction = finishedSelector;
    failedAction = failedSelector;
    target = t;
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",GETRECOMMENDLIST_URL,@"?client_type=iphone"]]];
    [request setRequestMethod:@"GET"];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(getListDidFinished:)];
    [request setDidFailSelector:@selector(getListDidFailed:)];
    [_operationQueue addOperation:request];
}
- (void)getListDidFinished:(ASIFormDataRequest *)request
{
    DBG(@"ASIFormDataRequest error = %@", [request error]);
    if (target && finishedAction) {
        [target performSelector:finishedAction withObject:[[request responseString] objectFromJSONString]];

    }
}
- (void)getListDidFailed:(ASIFormDataRequest *)request
{
    DBG(@"ASIFormDataRequest finished = %@", [request responseString]);
    if (target && failedAction) {
        [target performSelector:failedAction withObject:[request error]];
    }
}

- (void)writeImageToFileWithURL:(NSString *)imageURL
                   attachmentId:(NSString *)attId
                       callback:(id<ASIRequestServerCallback>)cb;
{
    [_callbackManager addObject:cb];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
    NSString *path = [[[PathManager sharedManager] recommendListImagesPath] stringByAppendingPathComponent:attId];
    [PathManager buildPath:path];
    request.queuePriority = NSOperationQueuePriorityHigh;
    [request setDownloadDestinationPath:path];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(requestComplete:)];
    [request setDidFailSelector:@selector(requestFailed:)];
    [_operationQueue addOperation:request];
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    DBG(@"request failed error = %@", [request error]);
    if ([_callbackManager count] > 0) {
        [_callbackManager removeLastObject];
    }
}

- (void)requestComplete:(ASIHTTPRequest *)request
{
    DBG(@"request failed error = %@", [request responseString]);

    if ([_callbackManager count] > 0) {
        [[_callbackManager lastObject] didFinishLoad:[[request responseString] objectFromJSONString]];
        [_callbackManager removeLastObject];
    }
}

@end
