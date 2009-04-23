extern VALUE rb_cTexture2D;

VALUE rb_cTexture2D_s_save_tex_parameters(VALUE klass);
VALUE rb_cTexture2D_s_set_alias_tex_parameters(VALUE klass);
VALUE rb_cTexture2D_s_restore_tex_parameters(VALUE klass);

void init_rb_cTexture2D();
