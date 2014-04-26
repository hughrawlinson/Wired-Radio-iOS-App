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
#import "STTwitter/STTwitter.h"

@interface ViewController : UIViewController <AVAudioPlayerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UIColor* wiredGold;
@property (strong, nonatomic) AVPlayer *audioPlayer;
@property (nonatomic) BOOL isPlaying;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *playButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *pauseButton;
@property (strong, nonatomic) IBOutlet UITableView *tweetTable;
@property (strong, nonatomic) NSArray *tweets;
@property (strong, nonatomic) STTwitterAPI *twitter;

-(IBAction) playAudio:(id)sender;
-(IBAction) pauseAudio:(id)sender;
@end
