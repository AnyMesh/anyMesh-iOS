#AnyMesh

AnyMesh is a multi-platform, decentralized, auto-discovery, auto-connect mesh networking API.  

Current supported platforms:

* Node.js
* iOS

AnyMesh makes it easy to build a decentralized, multi-platform mesh network on any LAN, without having to manually implement TCP / UDP processes.

All supported platforms work roughly the same way.  Configure each AnyMesh instance with 2 properties:

* Name - a name or identifier for the device / program
* ListensTo - an array of "subscriptions"

> AnyMesh will automatically find and connect to other AnyMesh
> instances.  (One AnyMesh instance per network adapter / IP address.)

Then, to communicate across the network, an instance can send two types of messages:

* Request - send a message to a specific device Name.
* Publish - send a message to any subscriber of your message's "target".

That's all there is to it!

#AnyMesh iOS

##Quickstart:
Create/access AnyMesh singleton:

    AnyMesh *am = [AnyMesh sharedInstance];
    am.delegate = self;
    
Enable connectivity:

    [am connectWithName:@"Dave" listeningTo:@[@"events", @"updates"]];

Send a request:

    [am requestToTarget:@"Bob" withData:@{@"msg":@"Hi Bob!"}];

Publish to subscribers:

    [am publishToTarget:@"events" withData:@{@"priority":@1, @"alert":"attention!"}];

Handle messages received:

    -(void)anyMeshReceivedMessage:(MeshMessage *)message  {
        //react to message
    }


###A few more helpful methods:

Get an array of MeshDeviceInfo objects:

    NSArray *activeConnections = [am getConnections];


Suspend and resume operation when required:

    [am suspend];    //put these in your Application Delegate where appropriate.
    [am resume];

###Any questions, comments, or suggestions, e-mail me (Dave) at davepaul0@gmail.com!







> Written with [StackEdit](https://stackedit.io/).
