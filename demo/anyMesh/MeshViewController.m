//
//  MeshViewController.m
//  anyMesh
//
//  Created by David Paul on 4/28/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import "MeshViewController.h"
#import "MeshMessage.h"
#import "DeviceCell.h"
#import "CellInfo.h"
#import "MeshDeviceInfo.h"

@implementation MeshViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        am = [AnyMesh sharedInstance];
        am.delegate = self;
        connectedDevices = [[NSMutableArray alloc] init];
        
            }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
    if (!am.name) {
        inputVC = [[InputViewController alloc] initWithNibName:@"InputViewController" bundle:nil];
        inputVC.delegate = self;
        [self presentViewController:inputVC animated:true completion:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_tableView registerNib:[UINib nibWithNibName:@"DeviceCell" bundle:[NSBundle mainBundle]]  forCellReuseIdentifier:@"Cell"];
    _msgField.delegate = self;
    _targetField.delegate = self;
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)publishButtonPressed:(id)sender {
    [am publishToTarget:_targetField.text withData:@{@"msg":_msgField.text}];
    
}
- (IBAction)requestButtonPressed:(id)sender {
    [am requestToTarget:_targetField.text withData:@{@"msg":_msgField.text}];
}


#pragma mark - TableView Datasource and Delegate Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [connectedDevices count];
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    CellInfo *info = [connectedDevices objectAtIndex:indexPath.row];
    cell.nameLabel.text = info.deviceInfo.name;
    cell.messageTextView.text = info.message;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

-(void)inputViewSubmittedWithInfo:(MeshDeviceInfo *)info
{
    [self dismissViewControllerAnimated:TRUE completion:nil];
    [am connectWithName:info.name listeningTo:info.listensTo];
    _nameLabel.text = [NSString stringWithFormat:@"Name: %@", info.name];
    NSMutableString *listensToString = [[NSMutableString alloc] initWithFormat:@"Listens To:"];
    for (NSString *listensToItem in info.listensTo) {
        [listensToString appendString:[NSString stringWithFormat:@"%@ ", listensToItem]];
    }
    _listensToLabel.text = listensToString;
}

#pragma mark - AnyMesh Delegate Methods
-(void)anyMeshConnectedTo:(MeshDeviceInfo *)device
{
    CellInfo *info = [[CellInfo alloc] init];
    info.deviceInfo = device;
    [connectedDevices addObject:info];
    [self.tableView reloadData];
}

-(void)anyMeshDisconnectedFrom:(NSString *)name
{
    CellInfo *objectToRemove;
    for (CellInfo *device in connectedDevices)
    {
        if ([device.deviceInfo.name isEqualToString:name]) {
            objectToRemove = device;
        }
    }
    if (objectToRemove)[connectedDevices removeObject:objectToRemove];
    
    [self.tableView reloadData];
}

-(void)anyMeshReceivedMessage:(MeshMessage *)message
{
    CellInfo *senderCell;
    for (CellInfo *device in connectedDevices)
    {
        if ([device.deviceInfo.name isEqualToString:message.sender]) {
            senderCell = device;
        }
    }
    if (senderCell){
        [connectedDevices removeObject:senderCell];
        [connectedDevices insertObject:senderCell atIndex:0];
        senderCell.message = message.data[@"msg"];
    }
    
    [self.tableView reloadData];
    
    
    NSLog(@"***************************");
    NSLog(@"Received message from %@", message.sender);
    NSLog(@"Message type:%d", message.type);
    NSLog(@"Message target:%@", message.target);
    NSLog(@"%@", [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:message.data options:0 error:nil] encoding:NSUTF8StringEncoding]);
    NSLog(@"****************************");
    
}

-(void)dismissKeyboard:(id)sender
{
    [_msgField resignFirstResponder];
    [_targetField resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return TRUE;
}

-(BOOL)shouldAutorotate
{
    return FALSE;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationPortrait;
}


@end
