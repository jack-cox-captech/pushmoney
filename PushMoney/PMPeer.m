//
//  PMPeer.m
//  PushMoney
//
//  Created by Jack Cox on 10/31/12.
//  Copyright (c) 2012 Jack Cox. All rights reserved.
//

#import "PMPeer.h"
#import "NetworkManager.h"

@implementation PMPeer

@synthesize conversation = _conversation;


- (void) setConversation:(Conversation *)conf {
    
    _conversation = conf;
    _conversation.peer = self;
    
}


@end
