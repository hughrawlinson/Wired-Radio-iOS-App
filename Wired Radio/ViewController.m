//
//  ViewController.m
//  Wired Radio
//
//  Created by Hugh Rawlinson on 17/03/2014.
//  Copyright (c) 2014 codeoclock. All rights reserved.
//

#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib
    NSURL *url = [NSURL URLWithString:@"http://owl.gold.ac.uk:8000/wired"];
    _audioPlayer = [[AVPlayer alloc] initWithURL:url];
    
    [_audioPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
    _isPlaying = YES;
    NSError *sessionError = nil;
    
    self.tweetTable.backgroundColor = [UIColor blackColor];
    self.tweetTable.opaque = YES;
    
    MPVolumeView* vv = [[MPVolumeView alloc] initWithFrame: CGRectMake(0, 0, 260, 20)];
    UIBarButtonItem* b = [[UIBarButtonItem alloc] initWithCustomView: vv];
    
    NSMutableArray *toolbarButtons = [[self.toolbar items] mutableCopy];
    [toolbarButtons insertObject:b atIndex:1];    // vary this index to put in diff spots in toolbar
    [self.toolbar setItems:toolbarButtons];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    
    [[AVAudioSession sharedInstance] setDelegate:self];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&sessionError];
    [[AVAudioSession sharedInstance] setActive:YES error:&sessionError];
    _twitter = [STTwitterAPI twitterAPIAppOnlyWithConsumerKey:@"Urr3pJs8q8eG2sOR4EMcQ" consumerSecret:@"ob5eSMtMPP4440s7a69pi6qkLtFdP5puG8RxGCXLac"];
    [_audioPlayer setVolume:1.0];
    
    [_twitter verifyCredentialsWithSuccessBlock:^(NSString *bearerToken) {
        NSLog(@"Access granted with %@", bearerToken);
        [self refreshTweets];
    } errorBlock:^(NSError *error) {
        NSLog(@"-- error %@", error);
    }];
}

- (void) refreshTweets{
    [_twitter getUserTimelineWithScreenName:@"wiredgold" successBlock:^(NSArray *statuses) {
        _tweets = statuses;
        //            for(int i = 0; i < _tweets.count; i++){
        //                NSLog(@"-- status%i: %@",i, [_tweets[i] objectForKey:@"text"]);
        //            }
        
        NSLog(@"%lu",(unsigned long)[_tweets count]);
        _tweetTable.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
        _tweetTable.hidden = NO;
        [_tweetTable reloadData];
        [_loading stopAnimating];
    } errorBlock:^(NSError *error) {
        NSLog(@"-- error: %@", error);
    }];
}

// If the user pulls out he headphone jack, stop playing.
- (void)audioRouteChangeListenerCallback:(NSNotification*)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (routeChangeReason) {
            
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            NSLog(@"AVAudioSessionRouteChangeReasonNewDeviceAvailable");
            NSLog(@"Headphone/Line plugged in");
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            NSLog(@"AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
            NSLog(@"Headphone/Line was pulled. Stopping player....");
            [self pauseAudio:NULL];
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            break;
    }
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    if (object == _audioPlayer && [keyPath isEqualToString:@"status"]) {
        if (_audioPlayer.status == AVPlayerStatusReadyToPlay) {
            [_audioPlayer play];
            [self setAsPlaying:YES];
        } else if (_audioPlayer.status == AVPlayerStatusFailed) {
            // something went wrong. player.error should contain some information
        }
    }
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    // If it is a remote control event handle it correctly
    if (event.type == UIEventTypeRemoteControl) {
        if (event.subtype == UIEventSubtypeRemoteControlPlay) {
            [_audioPlayer play];
            [self setAsPlaying:YES];
        } else if (event.subtype == UIEventSubtypeRemoteControlPause) {
            [_audioPlayer pause];
            [self setAsPlaying:NO];
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
        [self setAsPlaying:NO];
    }
    else{
        [_audioPlayer play];
        _isPlaying = YES;
        [self setAsPlaying:YES];
    }
}

-(IBAction) playAudio:(id)sender{
    [_audioPlayer play];
    [self setAsPlaying:YES];
}

-(IBAction) pauseAudio:(id)sender{
    [_audioPlayer pause];
    [self setAsPlaying:NO];
}

- (void) setAsPlaying:(BOOL)isPlaying
{
    self.isPlaying = isPlaying;
    
    // we need to change which of play/pause buttons are showing, if the one to
    // reverse current action isn't showing
    if ((isPlaying && !self.pauseButton) || (!isPlaying && !self.playButton))
    {
        UIBarButtonItem *buttonToRemove = nil;
        UIBarButtonItem *buttonToAdd = nil;
        if (isPlaying)
        {
            buttonToRemove = self.playButton;
            self.playButton = nil;
            self.pauseButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause
                                                                             target:self
                                                                             action:@selector(pauseAudio:)];
            buttonToAdd = self.pauseButton;
        }
        else
        {
            buttonToRemove = self.pauseButton;
            self.pauseButton = nil;
            self.playButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                                            target:self
                                                                            action:@selector(playAudio:)];
            buttonToAdd = self.playButton;
        }
        
        // Get the reference to the current toolbar buttons
        NSMutableArray *toolbarButtons = [[self.toolbar items] mutableCopy];
        
        // Remove a button from the toolbar and add the other one
        if (buttonToRemove)
            [toolbarButtons removeObject:buttonToRemove];
        if (![toolbarButtons containsObject:buttonToAdd])
            [toolbarButtons insertObject:buttonToAdd atIndex:0];    // vary this index to put in diff spots in toolbar
        
        [self.toolbar setItems:toolbarButtons];
    }
}

- (IBAction)togglePlayback:(id)sender {
    [self togglePlayback];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_tweets count];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tweetCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
    cell.textLabel.numberOfLines = 3;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    
    cell.textLabel.text = [[_tweets objectAtIndex:indexPath.row] objectForKey:@"text"];
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
//    CGSize maxSize = CGSizeMake(self.label.frame.size.width, MAXFLOAT);
//    
//    CGRect labelRect = [self.label.text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.label.font} context:nil];
//    
//    return CGsiz labelRect.size);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    /* here pop up Your subview with corresponding  value  from the array with array index indexpath.row ..*/
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

@end
