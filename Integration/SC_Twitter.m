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

#import "ruby.h"
#import "SC_common.h"
#import "SC_Twitter.h"

VALUE rb_mTwitter;

static char base64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
"abcdefghijklmnopqrstuvwxyz"
"0123456789"
"+/";

// basic encode64
int encode64(unsigned s_len, char *src, unsigned d_len, char *dst)
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

/*
 * perform a simple call to twitter
 */
int call_twitter(const char *user, const char *pass, const char *msg, NSString *url) {
	NSString *authStr = [NSString stringWithFormat:@"%s:%s", user, pass];
	NSData *encodeData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
	char encodeArray[512];
	memset(encodeArray, '\0', sizeof(encodeArray));
	encode64([encodeData length], (char *)[encodeData bytes], sizeof(encodeArray), encodeArray);
	
	NSString *fullAuthString = [NSString stringWithFormat:@"Basic %s", encodeArray];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
	[request addValue:fullAuthString forHTTPHeaderField:@"Authorization"];
	if (msg) {
		[request setHTTPMethod:@"POST"];
		[request setHTTPBody:[[NSString stringWithFormat:@"status=%s", msg] dataUsingEncoding:NSUTF8StringEncoding]];
	} else {
		[request setHTTPMethod:@"GET"];
	}
	NSURLResponse *response;
	NSError *error;
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	if (error == nil) {
		// return the status code
		return [(NSHTTPURLResponse *)response statusCode];
	} else
		return -1;//rb_str_new2([[error localizedDescription] cStringUsingEncoding:NSUTF8StringEncoding]);
}

/*
 * call-seq:
 *   Twitter.verify_credentials(user, pass)   #=> status code (integer)
 *
 * Test user/pass pair with twitter servers. You should check that the status
 * code is 200 (for success).
 */
VALUE rb_mTwitter_verify_credentials(VALUE module, VALUE rbuser, VALUE rbpass) {
	Check_Type(rbuser, T_STRING);
	Check_Type(rbpass, T_STRING);
	int response;
	if ((response = call_twitter(StringValueCStr(rbuser), StringValueCStr(rbpass), nil, @"http://twitter.com/account/verify_credentials.xml")) > 0) {
		return INT2FIX(response);
	}
	return Qnil;
}

/*
 * call-seq:
 *   Twitter.twitt(user, pass, message)   #=> nil or status code (as integer)
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
VALUE rb_mTwitter_twitt(VALUE module, VALUE rbuser, VALUE rbpass, VALUE rbmsg) {
	Check_Type(rbuser, T_STRING);
	Check_Type(rbpass, T_STRING);
	Check_Type(rbmsg, T_STRING);
	int response;
	if ((response = call_twitter(StringValueCStr(rbuser), StringValueCStr(rbpass), StringValueCStr(rbmsg), @"http://twitter.com/statuses/update.xml")) > 0) {
		return INT2FIX(response);
	}
	return Qnil;
}

void init_rb_mTwitter() {
	rb_mTwitter = rb_define_module_under(rb_mCocos2D, "Twitter");
	rb_define_module_function(rb_mTwitter, "verify_credentials", rb_mTwitter_verify_credentials, 2);
	rb_define_module_function(rb_mTwitter, "twitt", rb_mTwitter_twitt, 3);
}
