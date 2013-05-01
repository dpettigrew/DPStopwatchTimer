//
//  DPStopwatchTimer.m
//
//  Created by David Pettigrew on 12/18/12.
//  Copyright (c) David Pettigrew. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//      * Neither the name of the David Pettigrew nor the
//        names of its contributors may be used to endorse or promote products
//        derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL David Pettigrew BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//

#import "DPStopwatchTimer.h"

@interface DPStopwatchTimer ()

@property NSTimeInterval previousElapsedTime;
@property NSTimeInterval previousLapTime;
@property (nonatomic, copy) NSDate *startDate;
@property (nonatomic, copy) NSDate *lapStartDate;
@property (weak, nonatomic) NSTimer *timer;

@end

@implementation DPStopwatchTimer

- (id)init
{
    self = [super init];
    if (self) {
        _isPaused = YES;
    }
    return self;
}

- (void)restartTimeTimer
{
    _isPaused = NO;
    _lapStartDate = _startDate = [NSDate date];
    [_timer invalidate];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
}

- (void)pauseTiming {
    if (!_isPaused) {
        [self updateTime];
        _previousElapsedTime = _elapsedTime;
        _previousLapTime = _lapTime;
        _isPaused = YES;
        [_timer invalidate];
    }
}

- (void)resumeTiming {
    if (_isPaused) {
        [self restartTimeTimer];
    }
}

- (void)updateTime {
    NSDate *now = [NSDate date];
    _elapsedTime = [now timeIntervalSinceDate:_startDate];
    if (_previousElapsedTime > 0) {
        _elapsedTime += _previousElapsedTime;
    }
    _lapTime = [now timeIntervalSinceDate:_lapStartDate];
    if (_previousLapTime > 0) {
        _lapTime += _previousLapTime;
    }
    if ([_delegate respondsToSelector:@selector(stopwatch:didUpdate:lapTime:)]) {
        [_delegate stopwatch:self didUpdate:_elapsedTime lapTime:_lapTime];
    }
}

- (void)start {
    if (_isPaused) {
        [self resumeTiming];
    }
    else {
        [self restartTimeTimer];
    }
    if ([_delegate respondsToSelector:@selector(stopwatchDidStart:)]) {
        [_delegate stopwatchDidStart:self];
    }
}

- (void)stop {
    [self pauseTiming];
    if ([_delegate respondsToSelector:@selector(stopwatchDidStop:)]) {
        [_delegate stopwatchDidStop:self];
    }
}

- (void)reset {
    [_timer invalidate];
    _isPaused = YES;
    _elapsedTime = 0.0f;
    _lapTime = 0.0f;
    _previousElapsedTime = 0.0f;
    _previousLapTime = 0.0f;
    _lapStartDate = nil;
    _startDate = nil;
    if ([_delegate respondsToSelector:@selector(stopwatchDidReset:)]) {
        [_delegate stopwatchDidReset:self];
    }
}

- (void)lap {
    NSDate *now = [NSDate date];
    _lapTime = [now timeIntervalSinceDate:_lapStartDate];
    if ([_delegate respondsToSelector:@selector(stopwatchDidLap:lapTime:)]) {
        [_delegate stopwatchDidLap:self lapTime:_lapTime];
    }
    _lapStartDate = now;
    _previousLapTime = 0;
}

@end
