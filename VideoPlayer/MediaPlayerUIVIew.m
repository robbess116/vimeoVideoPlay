//
//  MediaPlayerUIVIew.m
//  vimeoVideo
//
//  Created by MacDev on 6/4/17.
//  Copyright © 2017 Robbess. All rights reserved.
//

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MediaPlayerUIVIew.h"
#import "YTVimeoExtractor.h"
@interface MediaPlayerUIVIew (){
    AVPlayerLayer *playerLayer;

    float originYViewVideoTool, originXLbVideoDurationTime, originHeightViewFlip;
    
}

@end

@implementation MediaPlayerUIVIew

+(id) customView {
    MediaPlayerUIVIew * recView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                                                 owner:self
                                                               options:nil] objectAtIndex:0];

    return recView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    _strVideoUrl = @"ghostcircle";
    
 
}

- (void) drawRect:(CGRect)rect {
      [self initView];
      [self initData];
      [self loadMediaPlayer];
}


- (void) initData {
    originYViewVideoTool = _viewVideoTool.frame.origin.y;
    originHeightViewFlip = _viewFlip.frame.size.height;
    originXLbVideoDurationTime = _lbVideoDurationTime.frame.origin.x;
    
    
}

-(void) initView {
   
    [_sliderVideo setThumbImage:[UIImage imageNamed:@"ic_seekplay"] forState:UIControlStateNormal];
    _sliderVideo.value = 0.0f;
    self.lbCurrentTime.text = @"00:00";
    self.lbVideoDurationTime.text = @"00:00";
    self.btnBigPlay.enabled = NO;
    self.btnSmallPlay.enabled = NO;
    self.imgViewPlaceholder.hidden = NO;
    self.backGNumber = 0;
    [_sliderVolume setThumbImage:[UIImage imageNamed:@"ic_seekvol"] forState:UIControlStateNormal];
    _viewFlip.hidden = YES;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPlayerToolbar:)];
    [_viewPlayer addGestureRecognizer:recognizer];
}

// videoView TapGesture
- (void) showPlayerToolbar:(UITapGestureRecognizer *) recognizer {
    CGRect rect = _viewVideoTool.frame;
    rect.origin.y = originYViewVideoTool-originHeightViewFlip;
    
    _btnFullScreen1.hidden = YES;
    CGRect rect2 = _lbVideoDurationTime.frame;
    rect2.origin.x = _btnFullScreen1.frame.origin.x;
    
    [UIView animateWithDuration:0.3 animations:^{
        _viewVideoTool.frame = rect;
        _lbVideoDurationTime.frame = rect2;
        
    } completion:^(BOOL finished) {
        _viewFlip.hidden = NO;
        [self performSelector:@selector(hideToolbar) withObject:nil afterDelay:4.0];
    }];
}

- (void) hideToolbar {
    [self hidePlayerToolbar:nil];
}

- (void) hidePlayerToolbar:(void(^)(BOOL fiished)) completion {
    
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(hideToolbar) object: nil];
    
    CGRect rect = _viewVideoTool.frame;
    rect.origin.y = originYViewVideoTool;
    _btnFullScreen1.hidden = NO;
    CGRect rect2 = _lbVideoDurationTime.frame;
    rect2.origin.x = originXLbVideoDurationTime;
    _viewFlip.hidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
        _viewVideoTool.frame = rect;
        _lbVideoDurationTime.frame = rect2;
        
    } completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
    }];
}

- (void) removeObserver {
    if (self.player != nil) {
        [self.player removeObserver:self forKeyPath:@"status"];
    }
}

- (void) addObserver {
    if (self.player != nil) {
        [self.player addObserver:self forKeyPath:@"status" options:0 context:nil];
    }
}

- (void)loadMediaPlayer {
    if(_strVideoUrl == nil){
        _strVideoUrl = @"ghostcircle";
    }
    [[YTVimeoExtractor sharedExtractor]fetchVideoWithVimeoURL:_strVideoUrl withReferer:nil completionHandler:^(YTVimeoVideo * _Nullable video, NSError * _Nullable error) {
        
        if (video) {
            
            
            //Will get the lowest available quality.
            //NSURL *lowQualityURL = [video lowestQualityStreamURL];
            
            //Will get the highest available quality.
            NSURL *highQualityURL = [video highestQualityStreamURL];
            if (self.player != nil)
                [self.player removeObserver:self forKeyPath:@"status"];
            self.player = [AVPlayer playerWithURL:highQualityURL];
            
            [self.player addObserver:self forKeyPath:@"status" options:0 context:nil];
            
            
            self.player.volume = 0.2;
            
            playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
            playerLayer.frame = _viewPlayer.bounds;
            
            _viewPlayer.clipsToBounds = true;
            [_viewPlayer.layer addSublayer:playerLayer];
            
            _isPlaying = NO;
            //self.backGNumber = 1;


            
        }else{
            
            UIAlertView *alertView = [[UIAlertView alloc]init];
            alertView.title = error.localizedDescription;
            alertView.message = error.localizedFailureReason;
            [alertView addButtonWithTitle:@"OK"];
            alertView.delegate = self;
            [alertView show];
            
            
        }
        
    }];

    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPlayerToolbar:)];
    [_viewPlayer addGestureRecognizer:recognizer];
    
    [_sliderVideo setThumbImage:[UIImage imageNamed:@"ic_seekplay"] forState:UIControlStateNormal];
    [_sliderVolume setThumbImage:[UIImage imageNamed:@"ic_seekvol"] forState:UIControlStateNormal];
    
    // Set the valueChanged target
    [_sliderVideo addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [_sliderVolume addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    if (object == self.player && [keyPath isEqualToString:@"status"]) {
        if (self.player.status == AVPlayerStatusReadyToPlay) {
            self.btnBigPlay.enabled = YES;
            self.btnSmallPlay.enabled = YES;
            CMTime duration = self.player.currentItem.asset.duration;
            float seconds = CMTimeGetSeconds(duration);
            _sliderVideo.maximumValue = seconds;
            //_sliderVideo.maximumValue = self.player.currentItem.asset.duration.value / self.player.currentItem.duration.timescale;
            
            // First, create NSDate object using
            NSDate* d = [[NSDate alloc] initWithTimeIntervalSince1970:_sliderVideo.maximumValue];
            // Then specify output format
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; [dateFormatter setDateFormat:@"mm:ss"];
            // And get output with
            NSString* result = [dateFormatter stringFromDate:d];
            _lbVideoDurationTime.text = result;
           

        } else if (self.player.status == AVPlayerStatusFailed) {
            // something went wrong. player.error should contain some information
            UIAlertView *alertView = [[UIAlertView alloc]init];
            alertView.title = @"error";
            alertView.message = @"Something went wrong!";
            [alertView addButtonWithTitle:@"OK"];
            alertView.delegate = self;
            [alertView show];
           
        }
    }
}
- (IBAction)onClickBtnBigPlay:(id)sender {
    _imgViewPlaceholder.hidden = YES;
    
    if(self.player) {
        if(_isPlaying) {
            [self.player pause];
            [_timer invalidate];
            _btnBigPlay.hidden = NO;
            _isPlaying = NO;
            self.backGNumber = 1;

            _imgViewSmallPlay.highlighted = NO;
        } else {
            
            _btnBigPlay.hidden = YES;
            _isPlaying = YES;
            self.backGNumber = 2;

            _imgViewSmallPlay.highlighted = YES;
            [self.player play];
            
            //[self performSelector:@selector(hidePlayerToolbar) withObject:nil afterDelay:2.0];
            // Set a timer which keep getting the current music time and update the UISlider in 1 sec interval
            _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(videoPlayingTime) userInfo:nil repeats:YES];
            // Set the maximum value of the UISlider
            
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
        }
    }
    
}

- (void) sliderChanged:(UISlider *) slider {
    if(slider == _sliderVideo) {
        [self.player seekToTime:CMTimeMake(slider.value , 1)];
    } else {
        self.player.volume = slider.value;
    }
}

- (void) videoPlayingTime{
    _sliderVideo.value = self.player.currentTime.value / self.player.currentTime.timescale;
    // First, create NSDate object using
    NSDate* d = [[NSDate alloc] initWithTimeIntervalSince1970:_sliderVideo.value];
    // Then specify output format
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; [dateFormatter setDateFormat:@"mm:ss"];
    // And get output with
    NSString* result = [dateFormatter stringFromDate:d];
    _lbCurrentTime.text = result;
}

- (void) playerDidFinishPlaying:(NSNotification*) note  {
    [_timer invalidate];
    [self.player seekToTime:CMTimeMake(0 , 1)];
    _sliderVideo.value = 0;
    _btnBigPlay.hidden = NO;
    _isPlaying = NO;
    self.backGNumber = 1;

    // First, create NSDate object using
    _lbCurrentTime.text = @"00:00";
    _imgViewSmallPlay.highlighted = NO;
    
}
- (void) playerPause{
        
    if(self.player) {
        if(_isPlaying) {
            [self.player pause];
            [_timer invalidate];
            _btnBigPlay.hidden = NO;
            _isPlaying = NO;
            self.backGNumber = 1;

            _imgViewSmallPlay.highlighted = NO;
        } else {
           
        }
    }

}

- (IBAction)onClickBtnBackward:(id)sender {
    if(self.player.rate > 0) {
        [self.player setRate: -self.player.rate * 2];
    } else {
        [self.player setRate: self.player.rate * 2];
    }

}
- (IBAction)onClickBtnForward:(id)sender {
    [self.player setRate: self.player.rate * 2.0];

}
- (IBAction)onClickVolumeUp:(id)sender {
    
}

@end
