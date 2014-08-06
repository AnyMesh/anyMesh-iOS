#AnyMesh
https://github.com/AnyMesh


AnyMesh is a multi-platform, decentralized, auto-discovery, auto-connect mesh networking API.

Current supported platforms:

* Node.js
* iOS
* Python

AnyMesh makes it easy to build a decentralized, multi-platform mesh network on any LAN, without having to manually implement TCP / UDP processes.

All supported platforms work roughly the same way.  Configure each AnyMesh instance with 2 properties:

* Name - a name or identifier for the instance
* ListensTo - an array of keywords for your instance to listen for

> AnyMesh will automatically find and connect to other AnyMesh
> instances.

Then, to communicate across the network, an instance can send two types of messages:

* Request - send a message to a specific device Name.
* Publish - send a message to associated with a keyword.  Any other instance that subscribes to the keyword will receive the message.

That's all there is to it!
## FAQ

### Q: So what is AnyMesh?
A: AnyMesh is a convenient, powerful way to get multiple programs to connect and send information to one another.
Each instance of AnyMesh will automatically find and connect to other instances.  AnyMesh instances can be running within the same app,
on separate apps on the same device, or on different devices within the same local network (LAN).

A network can contain any combination of these relationships, across any languages or platforms -
You may have a Mac OSX desktop computer running 2 instances of AnyMesh-Python alongside 1 instance of AnyMesh-Node.  These instances are
also connected to 2 more instances of AnyMesh-Node on a Linux computer down the hall, and a Raspberry Pi running AnyMesh-Python hardwired into the router.
Launch an app on your iPhone that uses AnyMesh-iOS, and instantly connect to all these devices automatically!

### Q: Why use AnyMesh instead of RabbitMQ, 0MQ, etc?
A: AnyMesh is certainly not the first mesh networking API on the block.  But AnyMesh was created with a few unique purposes in mind that sets it apart
from other libraries:

* AnyMesh is truly decentralized - Even at the lowest levels of the TCP connections, there is NO device acting as any kind of server or relay.
All AnyMesh instances manage their own connections to every other device.  This means any device can enter or leave the mesh at any time with ZERO disruption
to any other connections.
* AnyMesh has EXTREMELY minimal setup and configuration - Just name your instance and optionally give it some keywords to subscribe to.  There is no need to define roles for instances -
Every instance uses the same simple message distribution pattern.
* AnyMesh is multi-platform - We currently support iOS, Python, and Node.  We hope to start work on Java/Android very soon.


### Q: How can I help?
A: AnyMesh is still very young concept, and although it is fully functional, it will be a little while until we reach v.1.0 on all supported
platforms.  See the CONTRIBUTE.md file for suggestions on contributing to development.
#AnyMesh iOS
## Please Read:
0.3.0 has been released!  Multiple meshes on the same IP address, and even in the same app are now supported!  Please see the Changelog for complete list of changes!


##Quickstart:
CocoaPods is now the preferred method for installing AnyMesh-iOS or its example project. See cocoapods.org for information on installing and using CocoaPods.
To include AnyMesh to your project, add this to your Podfile:

    pod "AnyMesh", "~>0.3.0"

Or to quickly get going on a sample XCode project with Unit Tests, just type the following in Terminal:

    pod try AnyMesh

Once you have downloaded / imported AnyMesh into a project:

Create/access an AnyMesh instance:

    AnyMesh *am = [[AnyMesh alloc] init];
    am.delegate = self;

Enable connectivity:

    [am connectWithName:@"Dave" subscriptions:@[@"events", @"updates"]];

Send a request:

    [am requestToTarget:@"Bob" withData:@{@"msg":@"Hi Bob!"}];

Publish to subscribers:

    [am publishToTarget:@"events" withData:@{@"priority":@1, @"alert":"attention!"}];

Handle messages received:

    -(void)anyMesh:(AnyMesh*)anyMesh receivedMessage:(MeshMessage *)message  {
        //react to message
    }

###Some optional settings:

Change your network's ID (do this before connecting!)

    am = [[AnyMesh alloc] init];
    am.networkID = "upstairsDevices";
    am.delegate = ...
    [am connectWith....

> AnyMesh instances will only connect to other instances with the same network ID.  By setting the ID explicitly, you can have multiple "Meshes" on the same LAN and decide which instances belong to which mesh.  The default network ID on all AnyMesh platforms is "anymesh".

Change the UDP port used by AnyMesh (also do this before connecting!)

    am = [[AnyMesh alloc] init];
    am.discoveryPort = 54321;
    am.delegate = ...

> This is another way to control which instances can find each other, but it may also be useful if AnyMesh's default port (12345) is already being used on your network.

###A few more helpful methods:

Get an array of MeshDeviceInfo objects:

    NSArray *activeConnections = [am getConnections];


Suspend and resume operation when required:

    [am suspend];    //put these in your Application Delegate where appropriate.
    [am resume];

Update your instance's subscriptions:

    [am updateSubscriptions:@[@"events", @"updates", @"mobile"]];

More optional methods for your delegate to implement:

        //use these if your program wants to track information on connected instances:
        -(void)anyMesh:(AnyMesh*)anyMesh connectedTo:(MeshDeviceInfo *)device
        -(void)anyMesh:(AnyMesh*)anyMesh disconnectedFrom:(NSString *)name

        //if your program is keeping track of subscriptions for each connected instance, you may want to use this:
        -(void)anyMesh:(AnyMesh *)anyMesh updatedSubscriptions:(NSArray *)subscriptions forName:(NSString *)name;

###AnyMesh software is licensed with the MIT License

###Any questions, comments, or suggestions, contact the Author:
Dave Paul
davepaul0@gmail.com

