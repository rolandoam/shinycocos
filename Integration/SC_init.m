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
#import "Reachability.h"

VALUE rb_mCocos2D;
NSMutableDictionary *sc_object_hash;
NSMutableDictionary *sc_schedule_methods;
NSMutableDictionary *sc_handler_hash;

struct sc_funcall_param {
	VALUE recv;
	ID method_id;
	int n;
	VALUE *argv;
	int state;
};

#pragma mark Common

void sc_free(void *ptr) {
	CocosNode *obj = (CocosNode *)(((cocos_holder *)(ptr))->_obj);
	if (obj && [obj isKindOfClass:[CocosNode class]]) {
		obj.userData = nil; // we set this to nil because ruby has already cleared this
		[obj release];
	}
	xfree(ptr);
}

VALUE sc_init(VALUE klass, cocos_holder **ret_ptr, id object, int argc, VALUE *argv, BOOL release_on_free) {
	VALUE obj;
	cocos_holder *ptr;
	if (release_on_free)
		obj = Data_Make_Struct(klass, cocos_holder, 0, sc_free, ptr);
	else
		obj = Data_Make_Struct(klass, cocos_holder, 0, xfree, ptr);
	ptr->_obj = object;
	rb_obj_call_init(obj, argc, argv);
	if (ret_ptr != nil)
		*ret_ptr = ptr;
	return obj;
}

VALUE rb_hash_with_touch(UITouch *touch) {
	// touch should be a hash in the ruby world
	// with keys like :location, :tap_count, :timestamp
	CGPoint loc = [touch locationInView:[touch view]];
	NSUInteger taps = [touch tapCount];
	VALUE h = rb_hash_new();
	rb_hash_aset(h, sym_sc_location, rb_ary_new3(2, rb_float_new(loc.x), rb_float_new(loc.y)));
	rb_hash_aset(h, sym_sc_tap_count, INT2FIX(taps));
	return h;
}

VALUE rb_ary_with_set(NSSet *touches) {
	NSArray *arr = [touches allObjects];
	VALUE rb_arr = rb_ary_new2([arr count]);
	for (UITouch *touch in arr) {
		rb_ary_push(rb_arr, rb_hash_with_touch(touch));
	}
	return rb_arr;
}

/*
 * like rb_funcall, but check if the receiver responds to the method
 */
VALUE sc_funcall(struct sc_funcall_param *param) {
	VALUE ret = Qnil;
//	@synchronized(_appDelegate) {
		if (rb_obj_respond_to(param->recv, param->method_id, Qfalse))
			ret = rb_funcall3(param->recv, param->method_id, param->n, param->argv);
//	}
	return ret;
}

#define va_init_list(a,b) va_start(a,b)
VALUE sc_protect_funcall(VALUE recv, ID mid, int n, ...) {
	VALUE result;
	@synchronized(_appDelegate) {
		struct sc_funcall_param *p;
		va_list ar;
		va_init_list(ar, n);
		
		p = ALLOC(struct sc_funcall_param);
		p->state = 0;
		p->argv = nil;
		if (n > 0) {
			long i;
			p->argv = ALLOC_N(VALUE, n);
			p->recv = recv;
			p->method_id = mid;
			p->n = n;
			for (i = 0; i < n; i++) {
				p->argv[i] = va_arg(ar, VALUE);
			}
			va_end(ar);
		}
		else {
			p->recv = recv;
			p->method_id = mid;
			p->n = n;
		}
		
		// lock & load
		result = rb_protect(RUBY_METHOD_FUNC(sc_funcall), (VALUE)p, &(p->state));
		if (p->argv)
			xfree(p->argv);
		xfree(p);

		if (p->state != 0) {
			sc_error(p->state);
			result = Qnil;
		}
	}
	return result;
}

void sc_error(int state) {
	VALUE err    = rb_funcall(rb_gv_get("$!"), id_sc_message, 0, 0);
	// backtrace
	CCLOG(@"RubyError: %s", StringValueCStr(err));
	if (!NIL_P(ruby_errinfo)) {
		VALUE ary = rb_funcall(ruby_errinfo, rb_intern("backtrace"), 0);
		int c;
		for (c=0; c<RARRAY(ary)->len; c++) {
			CCLOG(@"\tfrom %s", RSTRING(RARRAY(ary)->ptr[c])->ptr);
		}		
	}
	/*
	VALUE err_bt = rb_gv_get("$@");
	VALUE err_bt_str = rb_funcall(err_bt, id_sc_join, 1, rb_str_new2("\n"));
	CCLOG(@"RubyError: %s\n%s",
		  StringValueCStr(err),
		  StringValueCStr(err_bt_str));
	*/
}


/*
 * call-seq:
 *   ns_log "something to log here", "something else here", [1,2,3], aRubyObject
 *  
 * NOTE: Use this with caution, this is really slow!
 * 
 * For every argument passed, if it's not a string, +inspect+ is called on it to convert it
 * to string.
 */
VALUE sc_ns_log(int argc, VALUE *argv, VALUE module) {
	/* create the template string */
	VALUE template_ary = rb_ary_new();
	int i;
	for (i=0; i < argc; i++) {
		if (TYPE(argv[i]) == T_STRING)
			sc_protect_funcall(template_ary, id_sc_push, 1, argv[i]);
		else
			sc_protect_funcall(template_ary, id_sc_push, 1, INSPECT(argv[i]));
	}
	VALUE template_final = sc_protect_funcall(template_ary, id_sc_join, 1, rb_str_new2(" "));	
	
	CCLOG([NSString stringWithCString:StringValueCStr(template_final) encoding:NSUTF8StringEncoding]);
	return Qnil;
}

/*
 * call-seq:
 *   Cocos2D.display_alert(title, msg, delegate, cancel_title, *buttons_title)   #=> nil
 *
 * Delegate can be nil.
 */
VALUE sc_display_alert(int argc, VALUE *argv, VALUE module) {
	if (argc < 4) {
		rb_raise(rb_eArgError, "Invalid number of arguments");
	}
	Check_Type(argv[0], T_STRING);
	Check_Type(argv[1], T_STRING);
	// TODO
	// Check that argv[2] is a CocosNode or nil
	Check_Type(argv[3], T_STRING);
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithCString:StringValueCStr(argv[0]) encoding:NSUTF8StringEncoding]
													message:[NSString stringWithCString:StringValueCStr(argv[1]) encoding:NSUTF8StringEncoding]
												   delegate:((argv[2] == Qnil) ? nil : CC_NODE(argv[2]))
										  cancelButtonTitle:[NSString stringWithCString:StringValueCStr(argv[3]) encoding:NSUTF8StringEncoding]
										  otherButtonTitles:nil];
	if (argc > 4) {
		int i;
		for (i=4; i < argc; i++) {
			[alert addButtonWithTitle:[NSString stringWithCString:StringValueCStr(argv[i]) encoding:NSUTF8StringEncoding]];
		}
	}
	[alert show];
	[alert release];
	return Qnil;
}


/*
 * call-seq:
 *   Cocos2D.reachability_for_host("myhost.com")   #=> integer
 *
 * Determines the reachability for the specified host. You should always
 * try to check for the reachability of a host before actually contacting it.
 *
 * Possible return values:
 *
 * * <tt>Cocos2D::NOT_REACHABLE</tt>
 * * <tt>Cocos2D::REACHABLE_VIA_CARRIER_DATA_NETWORK</tt>
 * * <tt>Cocos2D::REACHABLE_VIA_WIFI_NETWORK</tt>
 */
VALUE sc_reachability_for_host(VALUE module, VALUE host) {
	Check_Type(host, T_STRING);
	[Reachability sharedReachability].hostName = [NSString stringWithCString:RSTRING_PTR(host) encoding:NSUTF8StringEncoding];
	return INT2FIX([[Reachability sharedReachability] remoteHostStatus]);
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
	init_rb_mDirector();
	init_rb_cCocosNode();
	init_rb_cTextureNode();
	init_rb_cLabel();
	init_rb_cLabelAtlas();
	init_rb_cLayer();
	init_rb_cScene();
	init_rb_cSolidShapeMap();
	init_rb_cTransitionScene();
	init_rb_cTextureNode();
	init_rb_cSprite();
	init_rb_cAtlasSpriteManager();
	init_rb_cAtlasSprite();
	init_rb_cAtlasAnimation();
	init_rb_cMenu();
	init_rb_cMenuItemLabel();
	init_rb_cMenuItemImage();
	init_rb_cMenuItemAtlasSprite();
	init_rb_cTextField();
	init_rb_cSlider();
	init_rb_cAVAudioPlayer();
	init_rb_cBitmapFontAtlas();
	init_rb_cTMXTiledMap();
	init_rb_cTMXLayer();

	init_rb_mAction();
	init_rb_mUserDefaults();
	init_sc_cocoa_additions();
	
	/* common utility functions */
	rb_define_module_function(rb_mCocos2D, "ns_log", sc_ns_log, -1);
	rb_define_module_function(rb_mCocos2D, "display_alert", sc_display_alert, -1);
	rb_define_module_function(rb_mCocos2D, "reachability_for_host", sc_reachability_for_host, 1);
	
	/* no network conectivity */
	rb_define_const(rb_mCocos2D, "NOT_REACHABLE", INT2FIX(NotReachable));
	/* network conectivity through carrier */
	rb_define_const(rb_mCocos2D, "REACHABLE_VIA_CARRIER_DATA_NETWORK", INT2FIX(ReachableViaCarrierDataNetwork));
	/* network conectivity through wifi network */
	rb_define_const(rb_mCocos2D, "REACHABLE_VIA_WIFI_NETWORK", INT2FIX(ReachableViaWiFiNetwork));
}

extern void Init_zlib();

void Init_SC_Ruby_Extensions() {
	Init_zlib();
}
