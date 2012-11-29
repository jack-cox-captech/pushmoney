//
//  ConversationDelegate.h
//  PushMoney
//
//  Created by Jack Cox on 11/4/12.
//  Copyright (c) 2012 Jack Cox. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ConversationDelegate <NSObject>

@optional
- (void)errorInSend:(NSString *)error;
- (void)statusOfSend:(NSString *)status;

- (void)responseReceived:(NSDictionary *)response;
@end
