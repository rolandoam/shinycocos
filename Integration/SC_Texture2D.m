#import "SC_common.h"
#import "SC_Texture2D.h"

VALUE rb_cTexture2D;

VALUE rb_cTexture2D_s_save_tex_parameters(VALUE klass) {
	[Texture2D saveTexParameters];
	return Qnil;
}

VALUE rb_cTexture2D_s_set_alias_tex_parameters(VALUE klass) {
	[Texture2D setAliasTexParameters];
	return Qnil;
}

VALUE rb_cTexture2D_s_restore_tex_parameters(VALUE klass) {
	[Texture2D restoreTexParameters];
	return Qnil;
}

void init_rb_cTexture2D() {
	rb_cTexture2D = rb_define_class_under(rb_mCocos2D, "Texture2D", rb_cObject);
	rb_define_singleton_method(rb_cTexture2D, "save_tex_parameters", rb_cTexture2D_s_save_tex_parameters, 0);
	rb_define_singleton_method(rb_cTexture2D, "set_alias_tex_parameters", rb_cTexture2D_s_set_alias_tex_parameters, 0);
	rb_define_singleton_method(rb_cTexture2D, "restore_tex_parameters", rb_cTexture2D_s_restore_tex_parameters, 0);
}
