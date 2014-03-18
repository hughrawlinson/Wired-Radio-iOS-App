//
//  ViewController.m
//  Wired Radio
//
//  Created by Hugh Rawlinson on 17/03/2014.
//  Copyright (c) 2014 codeoclock. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib
    NSURL *url = [NSURL URLWithString:@"http://owl.gold.ac.uk:8000/wired"];
    _audioPlayer = [[AVPlayer alloc] initWithURL:url];
    [_audioPlayer play];
    _isPlaying = YES;
    NSError *sessionError = nil;
    
    
    [[AVAudioSession sharedInstance] setDelegate:self];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //Once the view has loaded then we can register to begin recieving controls and we can become the first responder
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    // If it is a remote control event handle it correctly
    if (event.type == UIEventTypeRemoteControl) {
        if (event.subtype == UIEventSubtypeRemoteControlPlay) {
            [_audioPlayer play];
        } else if (event.subtype == UIEventSubtypeRemoteControlPause) {
            [_audioPlayer pause];
        } else if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause) {
            [self togglePlayback];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) togglePlayback{
    if(_isPlaying){
        [_audioPlayer pause];
        _isPlaying = NO;
    }
    else{
        [_audioPlayer play];
        _isPlaying = YES;
    }
}

- (IBAction)j:(UIButton *)sender {
}

- (IBAction)togglePlayback:(id)sender {
    [self togglePlayback];
}
@end
