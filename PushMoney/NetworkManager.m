//
//  NetworkManager.m
//  PushMoney
//
//  Created by Jack Cox on 10/31/12.
//  Copyright (c) 2012 Jack Cox. All rights reserved.
//

#import "NetworkManager.h"
#import "PMPeer.h"
#import "Conversation.h"
#import "CatchMoneyConversation.h"

#define kGameKitSessionId       @"PushMoneySessionID"

@implementation NetworkManager
@synthesize session = _session;
static  NetworkManager *_singleton;

+ (NetworkManager *) sharedNetworkManager {
    if (_singleton == nil) {
        _singleton = [[NetworkManager alloc] init];
    }
    return _singleton;
}
- (id) init {
    self = [super init];
    if (self) {
        _peerList = [[NSMutableDictionary alloc] initWithCapacity:20];

    }
    return self;
}
#pragma mark GKSession 
/**
 * Called by a conversation object to accept a connection from a peer.
 *
 */
- (BOOL) acceptConnectFromPeer:(PMPeer *)peer error:(NSError **)error {
    NSLog(@"Accepting connection from peer");
    [_session acceptConnectionFromPeer:peer.peerID error:error];
    if (*error == nil) {
        NSLog(@"Error accepting connection from the peer");
        return NO;
    }
    return YES;
}

/**
 * Attempt to connect to a visible peer.  The connect timeout is 60 seconds. In non-debug modes the timeout should
 * be shorter
 *
 */
- (void) connectToPeer:(PMPeer *)peer {
    NSLog(@"Got connectToPeer:");
    [_session connectToPeer:peer.peerID withTimeout:60.0];
}
/**
 * disconnect from the specified peer.  The stateChange notification will change the state of the
 * conversation
 **/
- (void) disconnectFromPeer:(PMPeer *)peer {
    NSLog(@"Disconnecting from peer");
    [_session disconnectPeerFromAllPeers:peer.peerID];
}
/**
 * Returns the list of currently visible peers
 *
 */
- (NSArray *)getPeers {
    NSArray *peers =  [_session peersWithConnectionState:GKPeerStateAvailable];
    
    return peers;
}

/**
 * This method is called by GKSession when a data packet arrives.  This method locates the PMPeer to which
 * the session data belongs ad calls the conversation object associated with the peer
 *
 */
- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
    NSLog(@"Received data from peer %@", peer);
    
    PMPeer *pmPeer = [self peerForId:peer];
    if (pmPeer.conversation != nil) {
        [pmPeer.conversation receivedDataForConversation:data];
        
    }

}
/**
 * Send an NSDictionary as a payload to the peer.  The dictionary will be JSON encoded before transmission
 *
 **/
- (BOOL) sendData:(NSDictionary *)payload
           toPeer:(PMPeer *)peer
            error:(NSError **)error {
    NSLog(@"Sending data to peer");
    NSData *data =
      [NSJSONSerialization dataWithJSONObject:payload
                                      options:NSJSONWritingPrettyPrinted
                                        error:error];
    // return now if the NSDictionary didn't encode. This happens
    // if a key or value is not Foundaction object
    if (*error != nil) {
        NSLog(@"JSON building failed %@",
              [*error localizedDescription]);
        return NO;
    }
    // send the JSON payload
    [_session sendData:data
               toPeers:@[peer.peerID]
          withDataMode:GKSendDataReliable error:error];
    if (*error != nil) {
        NSLog(@"Transmitting the data failed");
        return NO;
    }
    return YES;
}

/**
 * Start a GK session. Should be called on app startup or resume.
 *
 **/
- (void)setupSession {
		
    [_peerList removeAllObjects];
	// create a new GameKit session
	_session = [[GKSession alloc] initWithSessionID:kGameKitSessionId displayName:nil sessionMode:GKSessionModePeer];
	
	// tell the session to use this manager as the event and data delegates
	_session.delegate = self;
	[_session setDataReceiveHandler:self withContext:nil];
    
}
/**
 * Make the app available to other peers
 *
 **/
- (void)startAcceptingInvitations {
	_session.available = YES;
}
/**
 * Make the app unavailable to other peers.
 *
 */
- (void)stopAcceptingInvitations {
	_session.available = NO;
}




#pragma mark GKSessionDelegate


/**
 * called by GKSession if the connection fails.
 *
 */
- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
    NSLog(@"connectionWithPeerFailed=%@",[error localizedDescription]);
	
	PMPeer *peer = [self peerForId:peerID];
    
    if(peer.conversation != nil) {
        [peer.conversation end];
        peer.conversation = nil;
    }
}

/**
 * Called when the entire GKSession failes.
 * The app reloads the peer list
 *
 **/
- (void)session:(GKSession *)session didFailWithError:(NSError*)error {
    NSLog(@"didFailWithError=%@",[error localizedDescription]);
	
	
}
/**
 * This delegate method is called when the session connects.
 **/
- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID {
    NSLog(@"Connection received from peer %@", peerID);
    PMPeer *peer = [self peerForId:peerID];
    peer.state = GKPeerStateConnecting;
    if (peer.conversation == nil) {
        
        // if there is no conversation then start one
        CatchMoneyConversation *conf = [[CatchMoneyConversation alloc] init];
        conf.delegate = conf;
        peer.conversation = conf;
        [peer.conversation start];
    }
    [peer.conversation changeConversationState:GKPeerStateConnecting];
}



/**
 * called by GKSession when the state of a connection with peer changes
 **/
- (void)session:(GKSession *)session
           peer:(NSString *)peerID
 didChangeState:(GKPeerConnectionState)state {
    
	switch (state) {
		case GKPeerStateAvailable:
        {
            // this peer became available
            NSString *dname = [_session displayNameForPeer:peerID];
			NSLog(@"Peer available %@:%@", peerID,dname);
            
            PMPeer *peer = [self peerForId:peerID];
            if (peer == nil) {
                NSLog(@"New peer");
                peer = [[PMPeer alloc] init];
                peer.peerID = peerID;
                peer.peerName = dname;
                [_peerList setObject:peer forKey:peerID];
            }
            peer.state = state;
            
            [self peerListChanged];
			
        }
			break;
			
		case GKPeerStateUnavailable:
        {
            NSLog(@"Peer unavailable %@", peerID);
            // this peer became unavailable
			PMPeer *peer = [self peerForId:peerID];
            
            if (peer != nil) {
                if (peer.conversation != nil) {
                    [peer.conversation changeConversationState:GKPeerStateUnavailable];
                }
                
                [_peerList removeObjectForKey:peerID];
            }
            [self peerListChanged];
        }
			break;
			
		case GKPeerStateConnected:
        {
            NSLog(@"Peer connected %@", peerID);
            // this peer accepted our connection
			PMPeer *peer = [self peerForId:peerID];
            if (peer.conversation != nil) {
                [peer.conversation changeConversationState:GKPeerStateConnected];
            } else {
                
            }
            
            
        }
			break;
			
		case GKPeerStateDisconnected:
        {
            NSLog(@"Peer disconnected %@", peerID);
            // this peer disconnected from the session
            PMPeer *peer = [self peerForId:peerID];
            peer.state = state;
            
            if (peer != nil) {
                if (peer.conversation != nil) {
                    [peer.conversation changeConversationState:GKPeerStateDisconnected];
                    peer.conversation = nil;
                }
            }
            [self peerListChanged];
        }
			break;
			
		default:
			break;
	}
}

#pragma mark session management

/**
 * Returns the peerID for the current session
 **/
- (NSString *)myPeerID {
    return _session.peerID;
}
/**
 * Get the PMPeer object that contains the specified peerID
 */
- (PMPeer *) peerForId:(NSString *)peerID {
    return [_peerList objectForKey:peerID];
}
/**
 * send out the notification that the peer list has changed and include a copy of the peer list
 **/
- (void)peerListChanged {
    [[NSNotificationCenter defaultCenter] postNotificationName:kPeerListChanged
                                                        object:self
                                                      userInfo:@{kPeerList:[[_peerList allValues] copy]}];
}



@end
