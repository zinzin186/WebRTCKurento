#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "KurentoToolbox.h"
#import "JSON-RPC.h"
#import "NBMJSONRPCClient.h"
#import "NBMJSONRPCClientDelegate.h"
#import "NBMJSONRPCConstants.h"
#import "NBMMessage.h"
#import "NBMRequest.h"
#import "NBMResponse.h"
#import "NBMEAGLRenderer.h"
#import "NBMEAGLVideoViewContainer.h"
#import "NBMMediaConfiguration.h"
#import "NBMPeerConnection.h"
#import "NBMRenderer.h"
#import "NBMTypes.h"
#import "NBMWebRTCPeer.h"
#import "WebRTC.h"
#import "NBMPeer.h"
#import "NBMRoom.h"
#import "NBMRoomClient.h"
#import "NBMRoomClientDelegate.h"
#import "NBMRoomConstants.h"
#import "NBMRoomError.h"
#import "Room.h"
#import "NBMTreeClient.h"
#import "NBMTreeClientDelegate.h"
#import "NBMTreeEndpoint.h"
#import "Tree.h"

FOUNDATION_EXPORT double KurentoToolboxVersionNumber;
FOUNDATION_EXPORT const unsigned char KurentoToolboxVersionString[];

