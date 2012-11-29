//
//  Conversation.h
//  PushMoney
//
//  Created by Jack Cox on 11/3/12.
//  Copyright (c) 2012 Jack Cox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "NetworkManager.h"
#import "PMPeer.h"
#import "ConversationDelegate.h"

@class PMPeer;

@interface Conversation : NSObject {
    NSString *_conversationID;
}

@property (assign, nonatomic) GKPeerConnectionState conversationState;
@property (readonly, nonatomic) NSString *conversationID;
@property (nonatomic, assign) id<ConversationDelegate>                   delegate;
@property (nonatomic, assign) PMPeer                *peer;

- (void) changeConversationState:(GKPeerConnectionState)newState;

- (void) receivedDataForConversation:(NSData *)data;
- (void)reportError:(NSString *)error;
- (void)reportStatusOfSend:(NSString *)status;
- (NSString *)newUUID;

- (void) start;
- (void) end;

@end
