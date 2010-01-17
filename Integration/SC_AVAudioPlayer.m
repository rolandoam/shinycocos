/*
 *   ShinyCocos - ruby bindings for the cocos2d-iphone game framework
 *   Copyright (C) 2009, Rolando Abarca M.
 *
 *   This library is free software; you can redistribute it and/or
 *   modify it under the terms of the GNU Lesser General Public
 *   License as published by the Free Software Foundation; either
 *   version 2.1 of the License.
 *
 *   This library is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *   Lesser General Public License for more details.
 *
 *   You should have received a copy of the GNU Lesser General Public
 *   License along with this library; if not, write to the Free Software
 *   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

#import "SC_common.h"
#import "SC_AVAudioPlayer.h"
#import <Foundation/Foundation.h>

VALUE rb_cAVAudioPlayer;

@implementation RBAudioPlayer

@synthesize userData;
@synthesize player;

- (id)initWithRubyObject:(VALUE)object file:(NSString *)file {
	if (self = [super init]) {
		NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:nil];
		player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil];
		player.delegate = (id)self;
		userData = object;
	}
	return self;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	if (userData) {
		sc_protect_funcall(userData, id_sc_av_player_did_finish_playing, 1, ((flag) ? Qtrue : Qfalse));
	}
}

- (void)dealloc {
	[player release];
	[super dealloc];
}
@end


/*
 * call-seq:
 *   AVAudioPlayer.new("soundfile")   #=> av audio player
 */
VALUE rb_cAVAudioPlayer_s_new(int argc, VALUE *argv, VALUE klass) {
	if (argc < 1) {
		rb_raise(rb_eArgError, "Invalid number of arguments");
	}
	Check_Type(argv[0], T_STRING);
	RBAudioPlayer *player = [[RBAudioPlayer alloc] initWithRubyObject:Qnil file:[NSString stringWithCString:StringValueCStr(argv[0]) encoding:NSUTF8StringEncoding]];
	VALUE ret = sc_init(klass, nil, player, argc-1, argv+1, YES);
	return ret;
}


/*
 * call-seq:
 *   player.play   #=> nil
 *
 * Starts playing the sound
 */
VALUE rb_cAVAudioPlayer_play(VALUE object) {
	[AV_PLAYER(object).player play];
	return Qnil;
}


/*
 * call-seq:
 *   player.stop   #=> nil
 *
 * Stops playing the sound
 */
VALUE rb_cAVAudioPlayer_stop(VALUE object) {
	[AV_PLAYER(object).player stop];
	return Qnil;
}


/*
 * call-seq:
 *   player.delegate = my_delegate   #=> my delegate
 *
 * delegate should implement player_did_finish_playing(successfully)
 */
VALUE rb_cAVAudioPlayer_set_delegate(VALUE object, VALUE delegate) {
	AV_PLAYER(object).userData = delegate;
	return delegate;
}


/*
 * call-seq:
 *   player.loops = loops   #=> Integer
 *
 * Set to 0 to play only once (default). Any positive number will loop that
 * many times. Any negative number will loop until you +stop+ it.
 */
VALUE rb_cAVAudioPlayer_set_loops(VALUE object, VALUE loop) {
	Check_Type(loop, T_FIXNUM);
	AV_PLAYER(object).player.numberOfLoops = FIX2INT(loop);
	return loop;
}


/*
 * call-seq:
 *   player.volume = volume   #=> volume (float)
 *
 * sets the volume. 1.0 = max volume, 0.0 = no volume
 */
VALUE rb_cAVAudioPlayer_set_volume(VALUE object, VALUE volume) {
	Check_Type(volume, T_FLOAT);
	AV_PLAYER(object).player.volume = NUM2DBL(volume);
	return volume;
}


/*
 * call-seq:
 *   player.volume   #=> volume (float)
 *
 * returns the volume. 1.0 = max volume, 0.0 = no volume
 */
VALUE rb_cAVAudioPlayer_volume(VALUE object) {
	return rb_float_new(AV_PLAYER(object).player.volume);
}


void init_rb_cAVAudioPlayer() {
	rb_cAVAudioPlayer = rb_define_class_under(rb_mCocos2D, "AVAudioPlayer", rb_cObject);
	rb_define_singleton_method(rb_cAVAudioPlayer, "new", rb_cAVAudioPlayer_s_new, -1);
	rb_define_method(rb_cAVAudioPlayer, "play", rb_cAVAudioPlayer_play, 0);
	rb_define_method(rb_cAVAudioPlayer, "stop", rb_cAVAudioPlayer_stop, 0);
	rb_define_method(rb_cAVAudioPlayer, "delegate=", rb_cAVAudioPlayer_set_delegate, 1);
	rb_define_method(rb_cAVAudioPlayer, "loops=", rb_cAVAudioPlayer_set_loops, 1);
	rb_define_method(rb_cAVAudioPlayer, "volume=", rb_cAVAudioPlayer_set_volume, 1);
	rb_define_method(rb_cAVAudioPlayer, "volume", rb_cAVAudioPlayer_volume, 0);
}
