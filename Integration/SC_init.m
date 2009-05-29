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

#import <Foundation/Foundation.h>
#import "SC_common.h"

VALUE rb_mCocos2D;
NSMutableDictionary *sc_object_hash;
NSMutableDictionary *sc_schedule_methods;
NSMutableDictionary *sc_handler_hash;

#pragma mark Common

static char base64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
"abcdefghijklmnopqrstuvwxyz"
"0123456789"
"+/";

int encode(unsigned s_len, char *src, unsigned d_len, char *dst)
{
	unsigned triad;
	
	for (triad = 0; triad < s_len; triad += 3)
	{
		unsigned long int sr;
		unsigned byte;
		
		for (byte = 0; (byte<3)&&(triad+byte<s_len); ++byte)
		{
			sr <<= 8;
			sr |= (*(src+triad+byte) & 0xff);
		}
		
		sr <<= (6-((8*byte)%6))%6; /*shift left to next 6bit alignment*/
		
		if (d_len < 4) return 1; /* error - dest too short */
		
		*(dst+0) = *(dst+1) = *(dst+2) = *(dst+3) = '=';
		switch(byte)
		{
			case 3:
				*(dst+3) = base64[sr&0x3f];
				sr >>= 6;
			case 2:
				*(dst+2) = base64[sr&0x3f];
				sr >>= 6;
			case 1:
				*(dst+1) = base64[sr&0x3f];
				sr >>= 6;
				*(dst+0) = base64[sr&0x3f];
		}
		dst += 4; d_len -= 4;
	}
	
	return 0;
	
}

void sc_free(void *ptr) {
	[GET_OBJC(ptr) release];
	free(ptr);
}

VALUE sc_init(VALUE klass, cocos_holder **ret_ptr, id object, int argc, VALUE *argv, BOOL release_on_free) {
	VALUE obj;
	cocos_holder *ptr;
	if (release_on_free)
		obj = Data_Make_Struct(klass, cocos_holder, 0, sc_free, ptr);
	else
		obj = Data_Make_Struct(klass, cocos_holder, 0, free, ptr);
	ptr->_obj = object;
	rb_obj_call_init(obj, argc, argv);
	if (ret_ptr != nil)
		*ret_ptr = ptr;
	return obj;
}

/*
 * use this with caution, this is really slow!
 */
VALUE sc_ns_log(int argc, VALUE *argv, VALUE module) {
	/* create the template string */
	VALUE template_ary = rb_ary_new();
	int i;
	for (i=0; i < argc; i++) {
		if (TYPE(argv[i]) == T_STRING)
			rb_funcall(template_ary, id_sc_push, 1, argv[i]);
		else
			rb_funcall(template_ary, id_sc_push, 1, INSPECT(argv[i]));
	}
	VALUE template_final = rb_funcall(template_ary, id_sc_join, 1, rb_str_new2(" "));	
	
	NSLog([NSString stringWithCString:StringValueCStr(template_final) encoding:NSUTF8StringEncoding]);
	return Qnil;
}

/*
 * call-seq:
 *   twitt(user, pass, message)   #=> nil or status code (as integer)
 *
 * Sends a twitt :-)
 * 
 * Your message should be less than 140 chars.
 *
 * returns the status code in case of connection success, you should check that
 * the status is 200.
 *
 *   if twitt(user, pass, "I just scored #{score} on this awesome game") == 200
 *     puts "everything went ok!"
 *   end
 */
VALUE sc_twitt(VALUE module, VALUE rbuser, VALUE rbpass, VALUE rbmsg) {
	Check_Type(rbuser, T_STRING);
	Check_Type(rbpass, T_STRING);
	Check_Type(rbmsg, T_STRING);
	NSString *authStr = [NSString stringWithFormat:@"%s:%s", StringValueCStr(rbuser), StringValueCStr(rbpass)];
	NSData *encodeData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray, '\0', sizeof(encodeArray));
	encode([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);
	
	//NSString *authStrEnc = [NSString stringWithCString:encodeArray encoding:NSUTF8StringEncoding];
	NSString *fullAuthString = [NSString stringWithFormat:@"Basic %s", encodeArray];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://twitter.com/statuses/update.json"]];
	[request setHTTPMethod:@"POST"];
	[request addValue:fullAuthString forHTTPHeaderField:@"Authorization"];
	[request setHTTPBody:[[NSString stringWithFormat:@"status=%s", StringValueCStr(rbmsg)] dataUsingEncoding:NSUTF8StringEncoding]];
	NSURLResponse *response;
	NSError *error;
	NSLog(@"about to twitt to %@", request);

	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	if (error == nil) {
		// return the status code
		return INT2FIX([(NSHTTPURLResponse *)response statusCode]);
	} else
		return rb_str_new2([[error localizedDescription] cStringUsingEncoding:NSUTF8StringEncoding]);
}

/*
 * ShinyCocos
 * 
 * ## Notes
 * 
 * The "vendor" directory is where you put your ruby code. Make sure
 * that when adding the directory to your project, the option "Create
 * Folder References for any added folder" is set. That way, the
 * directory structure will be created in the app package.
 */
void Init_ShinyCocos() {
	rb_mCocos2D = rb_define_module("Cocos2D");
	
	/* init mini object table */
	sc_object_hash = [[NSMutableDictionary alloc] init];
	sc_handler_hash = [[NSMutableDictionary alloc] init];
	sc_schedule_methods = [[NSMutableDictionary alloc] init];
	
	/* init the integration classes */
	init_sc_ids();
	init_rb_cTexture2D();
	init_rb_cDirector();
	init_rb_cCocosNode();
	init_rb_cScene();
	init_rb_cTextureNode();
	init_rb_cSprite();
	init_rb_cAtlasSpriteManager();
	init_rb_cAtlasSprite();
	init_rb_cAtlasAnimation();
	init_rb_cTiledMap();
	init_rb_cLayer();
	init_rb_cMenu();
	init_rb_cMenuItemImage();
	init_rb_cSolidShapeMap();
	init_rb_cMenuItemAtlasSprite();
	init_sc_cocoa_additions();
	
	/* common utility functions */
	rb_define_method(rb_mCocos2D, "ns_log", sc_ns_log, -1);
	rb_define_method(rb_mCocos2D, "twitt", sc_twitt, 3);
}

void Init_SC_Ruby_Extensions() {
	Init_encdb();
	Init_stringio();
	Init_syck();
	Init_zlib();
	// add your extensions init here!
}
