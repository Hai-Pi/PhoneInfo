//
//  TextFieldViewController.m
//  test
//
//  Created by tom on 2018/3/31.
//  Copyright © 2018年 TZ. All rights reserved.
//

#import "TextFieldViewController.h"

@interface TextFieldViewController ()
{UIImageView *_imageView; BOOL _isImage;}
@property (weak, nonatomic) IBOutlet UITextField *textField;
@end

@implementation TextFieldViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"11"]];
    [_imageView sizeToFit];
    CGRect rect = _imageView.frame;
    rect.size.height = 300;
    _imageView.frame = rect;
    _isImage = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismiss:(id)sender {
    if (self.textField.isFirstResponder) {
        [self.textField resignFirstResponder];
    }
}

- (IBAction)tap:(id)sender {
    if (_isImage) {
        self.textField.inputView = nil;
        _isImage = false;
    }else {
        self.textField.inputView = _imageView;
        _isImage = true;
    }
    [self.textField reloadInputViews];
}

@end
