//
//  ViewController.m
//  MSAlertControllerExample
//
//  Created by 鈴木大貴 on 2014/11/22.
//  Copyright (c) 2014年 鈴木大貴. All rights reserved.
//

#import "ViewController.h"
#import "MSAlertController.h"


@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

static NSString *const kCellIdentifier = @"Cell";
static NSInteger const kNumberOfRows = 2;
static NSArray *_cellNames = nil;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        static dispatch_once_t token;
        dispatch_once(&token, ^{
            _cellNames = @[@"Alert", @"Action Sheet"];
        });
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ViewController Private Methods
- (NSArray *)cellNames {
    return _cellNames;
}

- (void)showAlert {
    MSAlertController *alertController = [MSAlertController alertControllerWithTitle:@"MSAlertController" message:@"This is MSAlertController." preferredStyle:MSAlertControllerStyleAlert];
    
    MSAlertAction *action = [MSAlertAction actionWithTitle:@"Cancel" style:MSAlertActionStyleCancel handler:^(MSAlertAction *action) {
        NSLog(@"Cancel action tapped %@", action);
    }];
    [alertController addAction:action];
    
    MSAlertAction *action2 = [MSAlertAction actionWithTitle:@"Destructive" style:MSAlertActionStyleDestructive handler:^(MSAlertAction *action) {
        NSLog(@"Destructive action tapped %@", action);
    }];
    [alertController addAction:action2];
    
    MSAlertAction *action3 = [MSAlertAction actionWithTitle:@"Default" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action) {
        NSLog(@"Default action tapped %@", action);
    }];
    [alertController addAction:action3];
    
    [alertController addTextFieldWithConfigurationHandler:nil];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showActionSheet {
    MSAlertController *alertController = [MSAlertController alertControllerWithTitle:@"MSAlertController" message:@"This is MSAlertController." preferredStyle:MSAlertControllerStyleActionSheet];
    MSAlertAction *action = [MSAlertAction actionWithTitle:@"Cancel" style:MSAlertActionStyleCancel handler:^(MSAlertAction *action) {
        NSLog(@"Cancel action tapped %@", action);
    }];
    [alertController addAction:action];
    
    MSAlertAction *action2 = [MSAlertAction actionWithTitle:@"Destructive" style:MSAlertActionStyleDestructive handler:^(MSAlertAction *action) {
        NSLog(@"Destructive action tapped %@", action);
    }];
    [alertController addAction:action2];
    
    MSAlertAction *action3 = [MSAlertAction actionWithTitle:@"Default" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action) {
        NSLog(@"Default action tapped %@", action);
    }];
    [alertController addAction:action3];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kNumberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = self.cellNames[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    switch (indexPath.row) {
        case 0:
            [self showAlert];
            break;
            
        case 1:
            [self showActionSheet];
            break;
            
        default:
            break;
    }
}

@end
