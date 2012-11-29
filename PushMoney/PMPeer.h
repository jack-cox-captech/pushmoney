//
//  PMPeer.h
//  PushMoney
//
//  Created by Jack Cox on 10/31/12.
//  Copyright (c) 2012 Jack Cox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "Conversation.h"

@class Conversation;

@interface PMPeer : NSObject {
    Conversation *_conversation;
}

@property (strong, nonatomic) NSString  *peerID;
@property (strong, nonatomic) NSString  *peerName;
@property (assign, nonatomic) GKPeerConnectionState state;
@property (strong, nonatomic) Conversation *conversation;




@end
