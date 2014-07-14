//
//  MeshViewController.m
//  anyMesh
//
//  Created by David Paul on 4/28/14.
//  Copyright (c) 2014 dpTools. All rights reserved.
//

#import "MeshViewController.h"
#import "MeshMessage.h"
#import "MeshDeviceInfo.h"
#import "SetupView.h"
#import "CellData.h"
#import "SessionInfoView.h"

@implementation MeshViewController
@synthesize am;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        am = [[AnyMesh alloc] init];
        am.delegate = self;
        messages = [[NSMutableArray alloc] init];
        
            }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
    if (!am.name) {

        SetupView *sView = [[[NSBundle mainBundle] loadNibNamed:@"SetupView" owner:self options:nil] objectAtIndex:0];
        sView.parentController = self;
        sView.translatesAutoresizingMaskIntoConstraints = FALSE;
        [sView presentInView:self.view];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _msgField.delegate = self;
    _targetField.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)connectWithInfo:(MeshDeviceInfo *)info
{
    [am connectWithName:info.name subscriptions:info.subscriptions];
}

- (IBAction)publishButtonPressed:(id)sender {
    [am publishToTarget:_targetField.text withData:@{@"msg":_msgField.text}];
    
    CellData *cData = [[CellData alloc] init];
    cData.message = [NSString stringWithFormat:@"Published: %@", _msgField.text];
    cData.subTitle = [NSString stringWithFormat:@"Targeting all \"%@\" subscribers", _targetField.text];
    cData.color = [UIColor purpleColor];
    [messages addObject:cData];
    [self updateTableView];
    
}
- (IBAction)requestButtonPressed:(id)sender {
    [am requestToTarget:_targetField.text withData:@{@"msg":_msgField.text}];
    
    CellData *cData = [[CellData alloc] init];
    cData.message = [NSString stringWithFormat:@"Message sent: %@", _msgField.text];
    cData.subTitle = [NSString stringWithFormat:@"Requested to: %@", _targetField.text];
    cData.color = [UIColor purpleColor];
    [messages addObject:cData];
    [self updateTableView];
}

-(IBAction)infoButtonPressed:(id)sender
{
    SessionInfoView *sView = [[[NSBundle mainBundle] loadNibNamed:@"SessionInfoView" owner:self options:nil] objectAtIndex:0];
    sView.parentController = self;
    sView.nameLabel.text = am.name;
    sView.connectedDevices = [am connectedDevices];
    [sView presentInView:self.view];
}

-(void)updateTableView
{
    [_tableView reloadData];
    NSInteger rows = [_tableView numberOfRowsInSection:0];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(rows-1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:true];
    [self.view endEditing:TRUE];
}

#pragma mark - TableView Datasource and Delegate Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [messages count];
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }

    CellData *cData = [messages objectAtIndex:indexPath.row];
    cell.textLabel.text = cData.message;
    cell.detailTextLabel.text = cData.subTitle;
    cell.textLabel.textColor = cData.color;
    return cell;
}




#pragma mark - AnyMesh Delegate Methods
-(void)anyMesh:(AnyMesh*)anyMesh connectedTo:(MeshDeviceInfo *)device
{
    CellData *cData = [[CellData alloc] init];
    cData.message = @"New Connection";
    cData.subTitle = device.name;
    cData.color = [UIColor greenColor];
    
    [messages addObject:cData];
    [self updateTableView];
}

-(void)anyMesh:(AnyMesh*)anyMesh disconnectedFrom:(NSString *)name
{
    CellData *cData = [[CellData alloc] init];
    cData.message = @"Disconnected From";
    cData.subTitle = name;
    cData.color = [UIColor redColor];
    
    [messages addObject:cData];
    [self updateTableView];
}

-(void)anyMesh:(AnyMesh*)anyMesh receivedMessage:(MeshMessage *)message
{
    CellData *cData = [[CellData alloc] init];
    cData.message = [NSString stringWithFormat:@"Message: %@", message.data[@"msg"]];
    cData.subTitle = message.sender;
    cData.color = [UIColor blueColor];
    
    [messages addObject:cData];
    [self updateTableView];
    
}


#pragma mark - TextField
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (!recognizer) {
        recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
        [self.view addGestureRecognizer:recognizer];
    }
}

-(void)dismissKeyboard:(id)sender
{
    [self.view endEditing:TRUE];
    if (recognizer) {
        [self.view removeGestureRecognizer:recognizer];
        recognizer = nil;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:TRUE];
    if (recognizer) {
        [self.view removeGestureRecognizer:recognizer];
        recognizer = nil;
    }
    return TRUE;
}

#pragma mark - Orientation
-(BOOL)shouldAutorotate
{
    return FALSE;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationPortrait;
}


@end
