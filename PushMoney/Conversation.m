//
//  Conversation.m
//  PushMoney
//
//  Created by Jack Cox on 11/3/12.
//  Copyright (c) 2012 Jack Cox. All rights reserved.
//

#import "Conversation.h"


@implementation Conversation

@synthesize conversationID = _conversationID;

- (NSString *)newUUID {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge_transfer NSString *)string;
}

- (id) init {
    self = [super init];
    if (self) {
        
        _conversationID = [self newUUID];
        
        self.conversationState = GKPeerStateAvailable;
    }
    return self;
}

- (void) changeConversationState:(GKPeerConnectionState)state {
    NSLog(@"Changing conversation %@ state to %d", _conversationID, state);
}

- (void) receivedDataForConversation:(NSData *)data {
    NSLog(@"Received data for conversation %@", _conversationID);
}

- (void) start {
    NSLog(@"Starting conversation %@", _conversationID);
}

- (void) end {
    NSLog(@"Ending conversation %@", _conversationID);
    
    [[NetworkManager sharedNetworkManager] disconnectFromPeer:self.peer];
}

- (void)reportError:(NSString *)error {
    if ([self.delegate respondsToSelector:@selector(errorInSend:)]) {
        [self.delegate performSelector:@selector(errorInSend:)
                                withObject:@{@"peer":self.peer,
         @"error":error}];
    }
}
- (void)reportStatusOfSend:(NSString *)status {
    if ([self.delegate respondsToSelector:@selector(statusOfSend:)]) {
        [self.delegate performSelector:@selector(statusOfSend:)
                                withObject:@{@"peer":self.peer,
         @"status":status}];
    }
}



@end
