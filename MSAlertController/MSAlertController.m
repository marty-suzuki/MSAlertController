//
//  MSAlertController.m
//  MSAlertController
//
//  Created by 鈴木 大貴 on 2014/11/14.
//  Copyright (c) 2014年 Taiki Suzuki. All rights reserved.
//

#import "MSAlertController.h"
#import <QuartzCore/QuartzCore.h>
#import <MSAlertController/MSAlertController-Swift.h>
#import <SABlurImageView/SABlurImageView-Swift.h>
#import <MisterFusion/MisterFusion-Swift.h>

#pragma mark - MSAlertAction Class
NSString *const kAlertActionChangeEnabledProperty = @"kAlertActionChangeEnabledProperty";

#pragma mark - MSAlertController Class
@interface MSAlertController () <UIViewControllerTransitioningDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    UIColor *disabledColor;
}

@property (assign, nonatomic) MSAlertControllerStyle preferredStyle;
@property (copy, nonatomic) NSArray *actions;
@property (copy, nonatomic) NSArray *textFields;
@property (strong, nonatomic) MSAlertAnimation *animation;
@property (strong, nonatomic) UIButton *cancelButton;

// Views on Alert Controller
@property (weak, nonatomic) IBOutlet SABlurImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic, readwrite) IBOutlet UIView *tableViewContainer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// Views on Table View
@property (weak, nonatomic) UIView *tableViewHeader;
@property (weak, nonatomic) UILabel *titleLabel;
@property (weak, nonatomic) UILabel *messageLabel;

// Constraints of Table View Header
@property (weak, nonatomic) NSLayoutConstraint *superviewTitleConstraint;
@property (weak, nonatomic) NSLayoutConstraint *titleHeightConstraint;
@property (weak, nonatomic) NSLayoutConstraint *titleMessageConstraint;
@property (weak, nonatomic) NSLayoutConstraint *messageHeightConstraint;

// Only use when Alert Style
@property (strong, nonatomic) MSAlertHeaderView *__nullable alertHeaderView;
@property (weak, nonatomic) NSLayoutConstraint *messageTextFieldConstraint;
@property (weak, nonatomic) NSLayoutConstraint *textFieldHeightConstraint;
@property (weak, nonatomic) NSLayoutConstraint *textFieldSuperviewConstraint;

// Only use when Action Sheet Style
@property (strong, nonatomic) MSActionSheetHeaderView *__nullable actionSheetHeaderView;
@property (weak, nonatomic) NSLayoutConstraint *messageSuperviewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewContarinerSuperviewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewContainerWidthConstraint;

// Constraints of Table View
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewContainerBottomSpaceConstraint;

@end

@implementation MSAlertController

static NSString *const kCellReuseIdentifier = @"Cell";
static NSString *const kAlertControllerNameActionSheet = @"MSAlertController_ActionSheet";
static NSString *const kAlertControllerNameAlert = @"MSAlertController";

static CGFloat const kTextFieldHeight = 20.0f;
static CGFloat const kTextFieldWidth = 234.0f;

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(MSAlertControllerStyle)preferredStyle {
    return [[[self class] alloc] initWithTitle:title message:message preferredStyle:preferredStyle];
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(MSAlertControllerStyle)preferredStyle {
    NSString *nibName = nil;
    switch (preferredStyle) {
        case MSAlertControllerStyleActionSheet:
            nibName = kAlertControllerNameActionSheet;
            break;
        case MSAlertControllerStyleAlert:
            nibName = kAlertControllerNameAlert;
            break;
    }
    
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"MSAlertController" withExtension:@"bundle"];
    self = [super initWithNibName:nibName bundle:[NSBundle bundleWithURL:url]];
    if (self) {
        self.transitioningDelegate = self;
        
        self.title = title;
        self.message = message;
        
        if (preferredStyle == MSAlertControllerStyleAlert) {
            self.titleColor = [UIColor blackColor];
            self.titleFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f];
            self.messageColor = [UIColor blackColor];
            self.messageFont = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
        } else {
            self.titleColor = [UIColor colorWithRed:143.0f/255.0f green:143.0f/255.0f blue:143.0f/255.0f alpha:1.0f];
            self.titleFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f];
            self.messageColor = [UIColor colorWithRed:143.0f/255.0f green:143.0f/255.0f blue:143.0f/255.0f alpha:1.0f];;
            self.messageFont = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
        }
        
        self.actions = [NSArray array];
        self.textFields = [NSArray array];
        self.animation = [[MSAlertAnimation alloc] init];
        self.preferredStyle = preferredStyle;
        self.enabledBlurEffect = YES;
        self.backgroundColor = [UIColor grayColor];
        self.alpha = 0.5f;
        self.alertBackgroundColor = [UIColor whiteColor];
        self.separatorColor = [UIColor colorWithRed:231.0f/255.0f green:231.0f/255.0f blue:233.0f/255.0f alpha:1.0f];
        
        disabledColor = [UIColor colorWithRed:131.0f/255.0f green:131.0f/255.0f blue:131.0f/255.0f alpha:1.0f];
        
        switch (preferredStyle) {
            case MSAlertControllerStyleActionSheet:
                self.actionSheetHeaderView = [[MSActionSheetHeaderView alloc] init];
                break;
            case MSAlertControllerStyleAlert:
                self.alertHeaderView = [[MSAlertHeaderView alloc] init];
                break;
        }
    }
    return self;
}

#pragma mark - Getter
- (UILabel *)titleLabel {
    UILabel *titleLabel = nil;
    switch (self.preferredStyle) {
        case MSAlertControllerStyleActionSheet:
            titleLabel = self.actionSheetHeaderView.titleLabel;
            break;
        case MSAlertControllerStyleAlert:
            titleLabel = self.alertHeaderView.titleLabel;
            break;
    }
    return titleLabel;
}

- (UILabel *)messageLabel {
    UILabel *messageLabel = nil;
    switch (self.preferredStyle) {
        case MSAlertControllerStyleActionSheet:
            messageLabel = self.actionSheetHeaderView.messageLabel;
            break;
        case MSAlertControllerStyleAlert:
            messageLabel = self.alertHeaderView.messageLabel;
            break;
    }
    return messageLabel;
}

- (UIView *)tableViewHeader {
    UIView *tableViewHeader = nil;
    switch (self.preferredStyle) {
        case MSAlertControllerStyleActionSheet:
            tableViewHeader = self.actionSheetHeaderView;
            break;
        case MSAlertControllerStyleAlert:
            tableViewHeader = self.alertHeaderView;
            break;
    }
    return tableViewHeader;
}

- (NSLayoutConstraint *)superviewTitleConstraint {
    NSLayoutConstraint *superviewTitleConstraint = nil;
    switch (self.preferredStyle) {
        case MSAlertControllerStyleActionSheet:
            superviewTitleConstraint = self.actionSheetHeaderView.superviewTitleConstraint;
            break;
        case MSAlertControllerStyleAlert:
            superviewTitleConstraint = self.alertHeaderView.superviewTitleConstraint;
            break;
    }
    return superviewTitleConstraint;
}
- (NSLayoutConstraint *)titleHeightConstraint {
    NSLayoutConstraint *titleHeightConstraint = nil;
    switch (self.preferredStyle) {
        case MSAlertControllerStyleActionSheet:
            titleHeightConstraint = self.actionSheetHeaderView.titleHeightConstraint;
            break;
        case MSAlertControllerStyleAlert:
            titleHeightConstraint = self.alertHeaderView.titleHeightConstraint;
            break;
    }
    return titleHeightConstraint;
}

- (NSLayoutConstraint *)titleMessageConstraint {
    NSLayoutConstraint *titleMessageConstraint = nil;
    switch (self.preferredStyle) {
        case MSAlertControllerStyleActionSheet:
            titleMessageConstraint = self.actionSheetHeaderView.titleMessageConstraint;
            break;
        case MSAlertControllerStyleAlert:
            titleMessageConstraint = self.alertHeaderView.titleMessageConstraint;
            break;
    }
    return titleMessageConstraint;
}

- (NSLayoutConstraint *)messageHeightConstraint {
    NSLayoutConstraint *messageHeightConstraint = nil;
    switch (self.preferredStyle) {
        case MSAlertControllerStyleActionSheet:
            messageHeightConstraint = self.actionSheetHeaderView.messageHeightConstraint;
            break;
        case MSAlertControllerStyleAlert:
            messageHeightConstraint = self.alertHeaderView.messageHeightConstraint;
            break;
    }
    return messageHeightConstraint;
}

- (NSLayoutConstraint *)messageSuperviewConstraint {
    return self.actionSheetHeaderView.messageSuperviewConstraint;
}

- (NSLayoutConstraint *)messageTextFieldConstraint {
    return self.alertHeaderView.messageTextFieldConstraint;
}
- (NSLayoutConstraint *)textFieldHeightConstraint {
    return self.alertHeaderView.textFieldHeightConstraint;
}

- (NSLayoutConstraint *)textFieldSuperviewConstraint {
    return  self.alertHeaderView.textFieldSuperviewConstraint;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(relaodTableView:)
                                                 name:kAlertActionChangeEnabledProperty
                                               object:nil];
    
    self.view.frame = [UIScreen mainScreen].bounds;
    
    self.tableView.layer.cornerRadius = 6.0f;
    self.tableView.layer.masksToBounds = YES;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellReuseIdentifier];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
    self.tableView.scrollEnabled = NO;
    self.tableViewContainer.backgroundColor = [UIColor clearColor];
    
    self.alertHeaderView = [[MSAlertHeaderView alloc] init];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.imageView.image = [UIImage screenshot];
    if (self.enabledBlurEffect) {
        [self.imageView addBlurEffect:20 times:3];
    }
    
    self.tableView.separatorColor = self.separatorColor;
    
    self.backgroundView.backgroundColor = self.backgroundColor;
    self.backgroundView.alpha = self.alpha;
    
    self.titleLabel.text = self.title;
    self.titleLabel.textColor = self.titleColor;
    self.titleLabel.font = self.titleFont;
    
    self.messageLabel.text = self.message;
    self.messageLabel.textColor = self.messageColor;
    self.messageLabel.font = self.messageFont;
    
    NSInteger textFieldCount = self.textFields.count;
    self.textFieldHeightConstraint.constant = textFieldCount * kTextFieldHeight;
    self.alertHeaderView.textFieldContentView.backgroundColor = [UIColor whiteColor];
    [self.textFields enumerateObjectsUsingBlock:^(UITextField *textField, NSUInteger index, BOOL *stop) {
        CGRect textFieldFrame = textField.frame;
        textFieldFrame.origin.y = index * kTextFieldHeight;
        textField.frame = textFieldFrame;
        [self.alertHeaderView.textFieldContentView addSubview:textField];
    }];
    
    if (self.preferredStyle == MSAlertControllerStyleActionSheet) {
        CGSize windowSize = [UIScreen mainScreen].bounds.size;
        CGFloat width = windowSize.width;
        if (width > windowSize.height) {
            width = windowSize.height;
        }
        width -= 16.0f;
        self.tableViewContainerWidthConstraint.constant = width;
    }
    
    NSDictionary *options = @{ NSFontAttributeName : self.titleFont };
    CGRect boundingRect = [self.titleLabel.text boundingRectWithSize:CGSizeMake(kTextFieldWidth, NSIntegerMax)
                                                                options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                             attributes:options context:nil];
    self.titleHeightConstraint.constant = boundingRect.size.height;
    
    options = @{ NSFontAttributeName : self.messageFont };
    boundingRect = [self.messageLabel.text boundingRectWithSize:CGSizeMake(kTextFieldWidth, NSIntegerMax)
                                                             options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                          attributes:options context:nil];
    self.messageHeightConstraint.constant = boundingRect.size.height;
    
    CGFloat headerHeight = 0.0f;
    headerHeight += self.superviewTitleConstraint.constant;
    headerHeight += self.titleHeightConstraint.constant;
    headerHeight += self.titleMessageConstraint.constant;
    headerHeight += self.messageHeightConstraint.constant;
    if (self.preferredStyle == MSAlertControllerStyleAlert) {
        headerHeight += self.messageTextFieldConstraint.constant;
        headerHeight += self.textFieldHeightConstraint.constant;
        if (self.textFields.count < 1) {
            self.textFieldSuperviewConstraint.constant = 0.0f;
        }
        headerHeight += self.textFieldSuperviewConstraint.constant;
    } else {
        headerHeight += self.messageSuperviewConstraint.constant;
    }

    CGRect headerFrame = self.tableViewHeader.frame;
    headerFrame.size.height = headerHeight;
    self.tableViewHeader.frame = headerFrame;

    [self.tableViewHeader layoutIfNeeded];
    
    if (self.preferredStyle == MSAlertControllerStyleAlert) {
        CGFloat tableViewHeight = self.actions.count * 44.0f;
        self.tableViewHeightConstraint.constant = tableViewHeight + headerHeight - 1.0f;
    } else {
        NSInteger actionCount = self.actions.count;
        MSAlertAction *cancelAction = [self cancelAction];
        if (cancelAction != nil) {
            actionCount--;
        }
        CGFloat tableViewHeight = actionCount * 44.0f;
        if (cancelAction != nil) {
            self.tableViewBottomSpaceConstraint.constant = 52.0f;
            
            self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.cancelButton.userInteractionEnabled = cancelAction.enabled;
            self.cancelButton.layer.cornerRadius = 6.0f;
            self.cancelButton.layer.masksToBounds = YES;
            [self.cancelButton setTitle:cancelAction.title forState:UIControlStateNormal];
            if (cancelAction.enabled) {
                [self.cancelButton setTitleColor:cancelAction.titleColor forState:UIControlStateNormal];
            } else {
                [self.cancelButton setTitleColor:disabledColor forState:UIControlStateNormal];
            }
            self.cancelButton.titleLabel.font = cancelAction.font;
            [self.cancelButton addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            
            [self.tableViewContainer addLayoutSubview:self.cancelButton andConstraints:@[
                    self.cancelButton.Height.NotRelatedConstant(44.0f),
                    self.cancelButton.Left,
                    self.cancelButton.Right,
                    self.cancelButton.Top.Equal(self.tableView.Bottom).Constant(8.0f)
            ]];
        }
        
        self.tableViewContainerHeightConstraint.constant = tableViewHeight + headerHeight + self.tableViewBottomSpaceConstraint.constant - 0.5f;
        self.tableViewContarinerSuperviewConstraint.constant = -self.tableViewContainerHeightConstraint.constant;
    }
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = self.separatorColor;
    
    [self.tableViewHeader addLayoutSubview:line andConstraints:@[
        line.Height.NotRelatedConstant(0.5f),
        line.Left,
        line.Right,
        line.Bottom
    ]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (self.preferredStyle == MSAlertControllerStyleActionSheet && [self cancelAction] != nil) {
        UIImage *normalImage = [UIImage imageWithColor:self.alertBackgroundColor];
        [self.cancelButton setBackgroundImage:normalImage forState:UIControlStateNormal];
        UIImage *highlightedImage = [UIImage imageWithColor:[UIColor colorWithRed:217.0f/255.0f green:217.0f/255.0f blue:217.0f/255.0f alpha:1.0f]];
        [self.cancelButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    }
    
    [self.view layoutIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.preferredStyle == MSAlertControllerStyleActionSheet) {
        self.tableViewContarinerSuperviewConstraint.constant = 8.0f;
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {}];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.preferredStyle == MSAlertControllerStyleActionSheet) {
        self.tableViewContarinerSuperviewConstraint.constant = -self.tableViewContainerHeightConstraint.constant;
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {}];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    self.tableViewContainerBottomSpaceConstraint.constant = kbSize.height;
    [UIView animateWithDuration:0.3 animations:^(void) {
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.tableViewContainerBottomSpaceConstraint.constant = 0.0f;
    [UIView animateWithDuration:0.3 animations:^(void) {
        [self.view layoutIfNeeded];
    }];
}

- (MSAlertAction *)cancelAction {
    for (MSAlertAction *action in self.actions) {
        if (action.style == MSAlertActionStyleCancel) {
            return action;
        }
    }
    return nil;
}

- (void)relaodTableView:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (void)cancelButtonTapped:(id)sender {
    MSAlertAction *action = [self cancelAction];
    if ([action isKindOfClass:[MSAlertAction class]] && action.handler) {
        action.handler(action);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MSAlertController Public Methods
- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *))configurationHandler {
    if (self.preferredStyle == MSAlertControllerStyleActionSheet) {
        [NSException raise:@"NSInternalInconsistencyException" format:@"Text fields can only be added to an alert controller of style MSAlertControllerStyleAlert"];
        return;
    }

    NSMutableArray *textFields = self.textFields.mutableCopy;
    MSTextField *textField = [[MSTextField alloc] initWithFrame:CGRectMake(0, 0, kTextFieldWidth, kTextFieldHeight)];
    textField.borderStyle = UITextBorderStyleNone;
    textField.layer.borderWidth = 0.5f;
    textField.layer.borderColor = [UIColor grayColor].CGColor;
    textField.delegate = self;
    if (configurationHandler) {
        configurationHandler(textField);
    }
    [textFields addObject:textField];
    self.textFields = textFields.copy;
}

- (void)addAction:(MSAlertAction *)action {
    NSMutableArray *actions = self.actions.mutableCopy;
    if (action.style == MSAlertActionStyleCancel) {
        for (MSAlertAction *aa in actions) {
            if (aa.style == MSAlertActionStyleCancel) {
                [NSException raise:@"NSInternalInconsistencyException" format:@"MSAlertController can only have one action with a style of MSAlertActionStyleCancel"];
                return;
            }
        }
    }
    
    [actions addObject:action];
    [actions enumerateObjectsUsingBlock:^(MSAlertAction *aa, NSUInteger index, BOOL *stop) {
        NSUInteger lastIndex = actions.count - 1;
        if (aa.style == MSAlertActionStyleCancel && lastIndex != index) {
            [actions exchangeObjectAtIndex:index withObjectAtIndex:lastIndex];
            *stop = YES;
            return;
        }
    }];
    self.actions = actions.copy;
}

#pragma mark - UIViewControllerTransitioningDelegate Methods
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.animation.isPresenting = YES;
    return self.animation;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.animation.isPresenting = NO;
    return self.animation;
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.preferredStyle == MSAlertControllerStyleActionSheet && [self cancelAction] != nil) {
        return self.actions.count - 1;
    }
    return self.actions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier];
    
    MSAlertAction *action = [self.actions objectAtIndex:indexPath.row];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, cell.frame.size.height)];
    titleLabel.text = action.title;
    titleLabel.textColor = action.titleColor;
    titleLabel.font = action.font;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:titleLabel];
    
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    
    cell.separatorInset = UIEdgeInsetsZero;
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    
    cell.userInteractionEnabled = action.enabled;
    if (!action.enabled) {
        titleLabel.textColor = disabledColor;
    }
    
    if (action.normalColor) {
        cell.backgroundColor = action.normalColor;
    } else {
        cell.backgroundColor = self.alertBackgroundColor;
    }
    
    if (action.highlightedColor) {
        UIView *selectedBackgroundView = [[UIView alloc] init];
        selectedBackgroundView.backgroundColor = action.highlightedColor;
        cell.selectedBackgroundView = selectedBackgroundView;
    }
        
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - UITableViewDelegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    [self.tableViewHeader layoutIfNeeded];
    return CGRectGetHeight(self.tableViewHeader.frame);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    self.tableViewHeader.backgroundColor = self.alertBackgroundColor;
    return self.tableViewHeader;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    MSAlertAction *action = [self.actions objectAtIndex:indexPath.row];
    if ([action isKindOfClass:[MSAlertAction class]] && action.handler) {
        action.handler(action);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField canResignFirstResponder]) {
        [textField resignFirstResponder];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    return YES;
}

@end