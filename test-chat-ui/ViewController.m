//
//  ViewController.m
//  test-chat-ui
//
//  Created by Sergey Sedov on 12/26/15.
//  Copyright © 2015 Sergey Sedov. All rights reserved.
//

#import "ViewController.h"
#import "DataManager.h"
#import "LocationManager.h"
#import "ImageCache.h"

#import "TextCell.h"
#import "ImageCell.h"
#import "LocationCell.h"

#import "MessageBase.h"
#import "TextMessage.h"
#import "ImageMessage.h"
#import "LocationMessage.h"

#import "MapImageRenderer.h"
#import "BotService.h"

#import "UIImage+OrientationFix.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *sendTextButton;
@property (weak, nonatomic) IBOutlet UIButton *chooseActionButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyboardHeight;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[LocationManager sharedInstance] start];
    [[DataManager sharedInstance] start];

    self.textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.textView.layer.borderWidth = 1;
    self.textView.layer.cornerRadius = 5;
    
    self.tableView.transform = CGAffineTransformMakeScale(1, -1);
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.fetchedResultsController = [[DataManager sharedInstance] fetchedResultsControllerForMessages];
    self.fetchedResultsController.delegate = self;
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSAssert(NO, @"couldn't fetch messages: %@", error);
    }

    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(TextCell.class) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:NSStringFromClass(TextCell.class)];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(ImageCell.class) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:NSStringFromClass(ImageCell.class)];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(LocationCell.class) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:NSStringFromClass(LocationCell.class)];
    
    [self observeKeyboard];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self scrollToBottomAnimated:NO];
}

- (void)observeKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table view datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fetchedResultsController.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageBase *message = self.fetchedResultsController.fetchedObjects[indexPath.row];
    if ([message isKindOfClass:TextMessage.class]) {
        TextCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(TextCell.class) forIndexPath:indexPath];
        [cell configureWithMessage:(TextMessage *)message];
        cell.transform = CGAffineTransformMakeScale(1, -1);
        return cell;
    } else if ([message isKindOfClass:ImageMessage.class]) {
        ImageCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(ImageCell.class) forIndexPath:indexPath];
        cell.transform = CGAffineTransformMakeScale(1, -1);
        [cell configureWithMessage:(ImageMessage *)message];
        return cell;
    } else {
        LocationCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(LocationCell.class) forIndexPath:indexPath];
        MapImageRenderer *renderer = [[MapImageRenderer alloc] initInView:self.view];
        [cell configureWithMessage:(LocationMessage *)message mapRenderer: renderer];
        cell.transform = CGAffineTransformMakeScale(1, -1);
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageBase *message = self.fetchedResultsController.fetchedObjects[indexPath.row];
    if ([message isKindOfClass:TextMessage.class]) {
        return 60;
    } else if ([message isKindOfClass:ImageMessage.class]) {
        return 170;
    } else {
        return 220;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if ([self.textView isFirstResponder]) {
//        [self.textView resignFirstResponder];
//    }
}

- (void) scrollToBottomAnimated: (BOOL) animated {
    if (self.fetchedResultsController.fetchedObjects.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.fetchedResultsController.fetchedObjects.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

#pragma mark - actions

- (IBAction)onSendText:(id)sender {
    __weak typeof(self) weakSelf = self;
    [self enableSendButtons:NO];
    NSString *text = self.textView.text;
    [[DataManager sharedInstance] addTextMessage:text fromMe:YES withCompletion:^(BOOL result, NSError *error) {
        [weakSelf enableSendButtons:YES];
        if (!result) {
            [weakSelf showError:error];
        } else {
            weakSelf.textView.text = @"";
            [[BotService sharedInstance] scheduleTextMessage:text];
        }
    }];
}

- (IBAction)onChooseAction:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Choose message type" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *imageAction = [UIAlertAction actionWithTitle:@"Image" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf selectImage];
    }];
    UIAlertAction *locationAction = [UIAlertAction actionWithTitle:@"Current location" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf sendLocation];
    }];
    [alert addAction:imageAction];
    [alert addAction:locationAction];
    [self presentViewController:alert animated:YES completion:nil];
    return;
    
}

- (void) selectImage {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void) sendLocation {
    CLLocationCoordinate2D coordinate = [LocationManager sharedInstance].currentCoordinate;
    if (CLLocationCoordinate2DIsValid(coordinate)) {
        __weak typeof(self) weakSelf = self;
        [self enableSendButtons:NO];
        [[DataManager sharedInstance] addLocationMessage:coordinate fromMe:YES withCompletion:^(BOOL result, NSError *error) {
            [weakSelf enableSendButtons:YES];
            if (!result) {
                [weakSelf showError:error];
            } else {
                [[BotService sharedInstance] scheduleLocationMessage:coordinate];
            }
        }];
    }
}

- (void) enableSendButtons: (BOOL) enabled {
    if (!enabled && [self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
    }
    self.sendTextButton.enabled = enabled;
    self.chooseActionButton.enabled = enabled;
}

#pragma mark - error handling


- (void) showError: (NSError *) error {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
    return;
}

#pragma mark - image picker

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        UIImage *image = [info[UIImagePickerControllerOriginalImage] normalizedImage];
        if (image) {
            [weakSelf enableSendButtons:NO];
            [[ImageCache sharedInstance] saveImage:image withCompletion:^(NSString *fileName, NSError *error) {
                if (fileName) {
                    [[DataManager sharedInstance] addImageMessage:fileName width:image.size.width height:image.size.height fromMe:YES withCompletion:^(BOOL result, NSError *error) {
                        [weakSelf enableSendButtons:YES];
                        if (!result) {
                            [weakSelf showError:error];
                        } else {
                            [[BotService sharedInstance] scheduleImageMessage:fileName width:image.size.width height:image.size.height];
                        }
                    }];
                } else {
                    [weakSelf enableSendButtons:YES];
                    [weakSelf showError:error];
                }
            }];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - fetched controller


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void) configureCell: (UITableViewCell *) cell atIndexPath:(NSIndexPath *) indexPath {
    MessageBase *message = self.fetchedResultsController.fetchedObjects[indexPath.row];
    if ([cell isKindOfClass:TextCell.class]) {
        [(TextCell *) cell configureWithMessage:(TextMessage *)message];
        cell.transform = CGAffineTransformMakeScale(1, -1);
    } else if ([cell isKindOfClass:ImageCell.class]) {
        [(ImageCell *) cell configureWithMessage:(ImageMessage *)message];
        cell.transform = CGAffineTransformMakeScale(1, -1);
    } else {
        MapImageRenderer *renderer = [[MapImageRenderer alloc] initInView:self.view];
        [(LocationCell *) cell configureWithMessage:(LocationMessage *)message mapRenderer: renderer];
        cell.transform = CGAffineTransformMakeScale(1, -1);
    }
}

//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//    [self.tableView reloadData];
//    // так как обновлеие у нас сейчас состоит только из добавления новых сообщений - смотрим, если мы где-то внизу - скроллим вниз
//    __weak typeof(self) weakSelf = self;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        // берем нижнюю видимую ячейку
//        NSIndexPath *lastIndexPath = [[weakSelf.tableView indexPathsForVisibleRows] lastObject];
//        if (lastIndexPath && lastIndexPath.row > weakSelf.fetchedResultsController.fetchedObjects.count - 4) {
//            [weakSelf scrollToBottomAnimated:YES];
//        }
//    });
//}


#pragma mark - keyboard 

// The callback for frame-changing of keyboard
- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    CGFloat height = keyboardFrame.size.height;
    self.keyboardHeight.constant = height;
    CGPoint currentOffeset = self.tableView.contentOffset;
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
        [self.tableView setContentOffset:CGPointMake(currentOffeset.x, currentOffeset.y) animated:NO];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    self.keyboardHeight.constant = 0;
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}


@end
