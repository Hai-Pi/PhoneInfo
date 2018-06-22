//
//  ViewController.m
//  test
//
//  Created by tom on 16/01/2018.
//  Copyright © 2018 TZ. All rights reserved.
//

#import "ViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>

#import <CoreMotion/CoreMotion.h>

int K_COUNTDOWN = 15;

@interface ViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate, UIAccelerometerDelegate>
{
    NSTimer *_timer;
    AVCaptureSession *_session;
}
@property (nonatomic, strong) NSString *str;
@property (nonatomic, copy) NSString *str2;

@property (nonatomic, strong) NSMutableString *commonStr;

@property (nonatomic, strong) CMMotionManager *motionManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addObserver];
    [self addTimer];
    [self startDetectAmbientLight];
    [self startDetectShake];
}

- (void)startDetectShake {
    _motionManager = [[CMMotionManager alloc]init];
    _motionManager.accelerometerUpdateInterval = 1.0 / 1.0; // 数据更新时间间隔
    [_motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData,NSError *error) {
        double x = accelerometerData.acceleration.x;
        double y = accelerometerData.acceleration.y;
        double z = accelerometerData.acceleration.z;

        if (fabs(x)>2.0 ||fabs(y)>2.0 ||fabs(z)>2.0) {
//            NSLog(@"检测到晃动");
        }
//        NSLog(@"CoreMotionManager, x: %f,y: %f, z: %f",x,y,z);
    }];
}

- (void)startDetectAmbientLight {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:device error:nil];

    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [output setSampleBufferDelegate:self queue:dispatch_get_main_queue()];

    _session = [AVCaptureSession new];
    if ([_session canAddInput:input]) {
        [_session addInput:input];
    }
    if ([_session canAddOutput:output]) {
        [_session addOutput:output];
    }

    [_session startRunning];
}

- (void)addTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    [_timer fire];
}

- (void)countDown:(NSTimer*)timer {
    K_COUNTDOWN--;
    if (K_COUNTDOWN <= 0) {
        [timer invalidate];
        timer = nil;
    }
//    NSLog(@"K_COUNTDOWN is: %d", K_COUNTDOWN);
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidAction:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)orientationDidAction:(NSNotification*)notification {
    NSDictionary *info = notification.userInfo;
//    NSLog(@"info is:%@", info);
}

- (void)getBundle {
    NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(@"test")];
    NSString *resourcePath = bundle.resourcePath;
    NSString *bundlePath = [resourcePath stringByAppendingPathComponent:@"test.bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:bundlePath];
    NSString *imagePath = [resourceBundle pathForResource:@"WX20180316-174045" ofType:@"png" inDirectory:@"Images"];
    imagePath;
}

- (void)setGradientColor {
    NSMutableArray *colors = @[].mutableCopy;

    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.frame = self.view.bounds;
    for (int i = 0; i < 5; i++) {
        [colors addObject:[UIColor colorWithRed:arc4random() % 100 / 255.0 green:arc4random() % 100 / 255.0 blue:arc4random() % 100 / 255.0 alpha:1].CGColor];
    }
    layer.colors = colors;
    layer.startPoint = CGPointMake(0, 1);
    layer.endPoint = CGPointMake(1, 0);
    [self.view.layer insertSublayer:layer atIndex:0];
}

- (IBAction)clicked:(id)sender {
//    liveManager.actionCount = 1;
//    liveManager.actionTimeOut = 10;
//    liveManager.randomAction = YES;
//
//    [liveManager startFaceDecetionViewController:self
//                                          finish:^(FaceIDData *finishDic, UIViewController *viewController) {
//
//                                          }error:^(MGLivenessDetectionFailedType errorType, UIViewController *viewController) {
//
//                                          }];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {

    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];

//    NSLog(@"%f",brightnessValue);


    // 根据brightnessValue的值来打开和关闭闪光灯
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    BOOL result = [device hasTorch];// 判断设备是否有闪光灯
    if ((brightnessValue < 0) && result) {// 打开闪光灯

        [device lockForConfiguration:nil];

//        [device setTorchMode: AVCaptureTorchModeOn];//开

        [device unlockForConfiguration];

    }else if((brightnessValue > 0) && result) {// 关闭闪光灯

        [device lockForConfiguration:nil];
//        [device setTorchMode: AVCaptureTorchModeOff];//关
        [device unlockForConfiguration];

    }

}

@end
