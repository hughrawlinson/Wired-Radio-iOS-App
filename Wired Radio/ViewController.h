//
//  ViewController.h
//  Wired Radio
//
//  Created by Hugh Rawlinson on 17/03/2014.
//  Copyright (c) 2014 codeoclock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController <AVAudioPlayerDelegate>

@property (strong, nonatomic) UIColor* wiredGold;
@property (strong, nonatomic) AVPlayer *audioPlayer;
@property (nonatomic) BOOL isPlaying;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loading;

- (IBAction)togglePlayback:(id)sender;
@end
