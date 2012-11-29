//
//  NetworkManager.h
//  PushMoney
//
//  Created by Jack Cox on 10/31/12.
//  Copyright (c) 2012 Jack Cox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

#define kPeerListChanged    @"peerListChanged"
#define kPeerList           @"peerList"

@class PMPeer;

@interface NetworkManager : NSObject <GKSessionDelegate> {
    GKSession           *_session;
    
    NSMutableDictionary      *_peerList;

}

@property (readonly, nonatomic) GKSession *session;

/* Gets the singleton NetworkManager
 */
+ (NetworkManager *) sharedNetworkManager;
/* Start the GKSession. Suitable for startup and returning to foreground mode
 */
- (void)setupSession;
/* Start accepting connections from GKSession. The app will not become available until this is called
 */
- (void)stopAcceptingInvitations;
/* Stop accepting connection requests from GKSession
 */
- (void)startAcceptingInvitations;
/* Gets the peer ID for this device.
 */
- (NSString *)myPeerID;


/* Send a connection request to the specified peer
 */
- (void) connectToPeer:(PMPeer *)peer;
/* Accept a connection request from a pper 
 */
- (BOOL) acceptConnectFromPeer:(PMPeer *)peer
                         error:(NSError **)error;

/* Called by GKSession when data arrives for this peer
 */
- (void) receiveData:(NSData *)data
            fromPeer:(NSString *)peer
           inSession:(GKSession *)session
             context:(void *)context;

/* Get the list of peers
 */
- (NSArray *)getPeers;

/* Send an NSDictionary to a peer
 */
- (BOOL) sendData:(NSDictionary *)payload
           toPeer:(PMPeer *)peer
            error:(NSError **)error ;

/* Disconnect from a peer 
 */
- (void) disconnectFromPeer:(PMPeer *)peer;
@end
