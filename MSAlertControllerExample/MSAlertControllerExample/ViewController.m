//
//  ViewController.m
//  MSAlertControllerExample
//
//  Created by 鈴木大貴 on 2014/11/22.
//  Copyright (c) 2014年 鈴木大貴. All rights reserved.
//

#import "ViewController.h"
#import "MSAlertController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showAlertButtonTapped:(id)sender {
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

- (IBAction)showActionSheetButtonTapped:(id)sender {
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


@end
