//
//  ViewController.m
//  MSAlertControllerExample
//
//  Created by 鈴木大貴 on 2014/11/22.
//  Copyright (c) 2014年 鈴木大貴. All rights reserved.
//

#import "ViewController.h"
#import "MSAlertController.h"
#import "SACollectionViewVerticalScalingFlowLayout.h"
#import "SACollectionViewVerticalScalingCell.h"

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation ViewController

static NSString *const kCellIdentifier = @"Cell";
static NSArray *_imageNames = nil;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        static dispatch_once_t token;
        dispatch_once(&token, ^{
            _imageNames = @[@"alert", @"actionsheet", @"custom"];
        });
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    SACollectionViewVerticalScalingFlowLayout *layout = [[SACollectionViewVerticalScalingFlowLayout alloc] init];
    layout.scaleMode = SACollectionViewVerticalScalingFlowLayoutScaleModeHard;
    layout.alphaMode = SACollectionViewVerticalScalingFlowLayoutAlphaModeEasy;
    self.collectionView.collectionViewLayout = layout;
    
    [self.collectionView registerClass:[SACollectionViewVerticalScalingCell class] forCellWithReuseIdentifier:kCellIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ViewController Private Methods
- (NSArray *)imageNames {
    return _imageNames;
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

- (void)showCustomAlert {
    MSAlertController *alertController = [MSAlertController alertControllerWithTitle:@"MSAlertController" message:@"This is MSAlertController." preferredStyle:MSAlertControllerStyleAlert];
    alertController.titleFont = [UIFont fontWithName:@"Baskerville-BoldItalic" size:18.0f];
    alertController.messageFont = [UIFont fontWithName:@"Baskerville-BoldItalic" size:18.0f];
    alertController.alertBackgroundColor = [UIColor orangeColor];
    alertController.backgroundColor = [UIColor greenColor];
    alertController.alpha = 0.4f;
    alertController.separatorColor = [UIColor whiteColor];
    
    MSAlertAction *action = [MSAlertAction actionWithTitle:@"Cancel" style:MSAlertActionStyleCancel handler:^(MSAlertAction *action) {
        //Write a code for this action.
    }];
    action.normalColor = [UIColor yellowColor];
    action.highlightedColor = [UIColor whiteColor];
    action.titleColor = [UIColor redColor];
    action.font = [UIFont fontWithName:@"Baskerville-BoldItalic" size:18.0f];
    [alertController addAction:action];
    
    MSAlertAction *action2 = [MSAlertAction actionWithTitle:@"Destructive" style:MSAlertActionStyleDestructive handler:^(MSAlertAction *action) {
        NSLog(@"Destructive action tapped %@", action);
    }];
    action2.normalColor = [UIColor cyanColor];
    action2.highlightedColor = [UIColor whiteColor];
    action2.titleColor = [UIColor redColor];
    action2.font = [UIFont fontWithName:@"Baskerville-BoldItalic" size:18.0f];
    [alertController addAction:action2];
    
    MSAlertAction *action3 = [MSAlertAction actionWithTitle:@"Default" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action) {
        NSLog(@"Default action tapped %@", action);
    }];
    action3.normalColor = [UIColor redColor];
    action3.highlightedColor = [UIColor purpleColor];
    action3.titleColor = [UIColor whiteColor];
    action3.font = [UIFont fontWithName:@"Baskerville-BoldItalic" size:18.0f];
    [alertController addAction:action3];
    
    [alertController addTextFieldWithConfigurationHandler:nil];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageNames.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SACollectionViewVerticalScalingCell *cell = (SACollectionViewVerticalScalingCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    UIImage *image = [UIImage imageNamed:self.imageNames[indexPath.row]];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.bounds];
    imageView.image = image;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cell.containerView addSubview:imageView];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate Methods
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];

    switch (indexPath.row) {
        case 0:
            [self showAlert];
            break;
            
        case 1:
            [self showActionSheet];
            break;
        
        case 2:
            [self showCustomAlert];
            break;
            
        default:
            break;
    }
}

@end
