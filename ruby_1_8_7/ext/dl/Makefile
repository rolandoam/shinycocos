
SHELL = /bin/sh

#### Start of system configuration section. ####
top_srcdir = $(topdir)/.
srcdir = $(top_srcdir)/ext/dl
topdir = ../..
hdrdir = $(top_srcdir)
VPATH = $(srcdir):$(topdir):$(hdrdir)
RUBYLIB = -
RUBYOPT = -rpurelib.rb
exec_prefix = $(prefix)
prefix = $(DESTDIR)/usr/local
sharedstatedir = $(prefix)/com
mandir = $(datarootdir)/man
psdir = $(docdir)
oldincludedir = $(DESTDIR)/usr/include
localedir = $(datarootdir)/locale
bindir = $(exec_prefix)/bin
libexecdir = $(exec_prefix)/libexec
sitedir = $(libdir)/ruby/site_ruby
htmldir = $(docdir)
vendorarchdir = $(vendorlibdir)/$(sitearch)
includedir = $(prefix)/include
infodir = $(datarootdir)/info
vendorlibdir = $(vendordir)/$(ruby_version)
sysconfdir = $(prefix)/etc
libdir = $(exec_prefix)/lib
sbindir = $(exec_prefix)/sbin
rubylibdir = $(libdir)/ruby/$(ruby_version)
docdir = $(datarootdir)/doc/$(PACKAGE)
dvidir = $(docdir)
vendordir = $(libdir)/ruby/vendor_ruby
datarootdir = $(prefix)/share
pdfdir = $(docdir)
archdir = $(rubylibdir)/$(arch)
sitearchdir = $(sitelibdir)/$(sitearch)
datadir = $(datarootdir)
localstatedir = $(prefix)/var
sitelibdir = $(sitedir)/$(ruby_version)

CC = gcc
LIBRUBY = $(LIBRUBY_A)
LIBRUBY_A = lib$(RUBY_SO_NAME)-static.a
LIBRUBYARG_SHARED = 
LIBRUBYARG_STATIC = -l$(RUBY_SO_NAME)-static

RUBY_EXTCONF_H = 
CFLAGS   =  -fno-common -g -O2 -pipe -fno-common $(cflags) -fno-defer-pop -fno-omit-frame-pointer 
INCFLAGS = -I. -I../.. -I../../. -I../.././ext/dl
DEFS     = 
CPPFLAGS = -DHAVE_DLFCN_H -DHAVE_DLOPEN -DHAVE_DLCLOSE -DHAVE_DLSYM -DHAVE_DLERROR  -D_XOPEN_SOURCE -D_DARWIN_C_SOURCE   -I.
CXXFLAGS = $(CFLAGS) 
ldflags  = -L. 
dldflags = 
archflag = 
DLDFLAGS = $(ldflags) $(dldflags) $(archflag)
LDSHARED = cc -dynamic -bundle -undefined suppress -flat_namespace
AR = ar
EXEEXT = 

RUBY_INSTALL_NAME = ruby
RUBY_SO_NAME = ruby
arch = i686-darwin9.8.0
sitearch = i686-darwin9.8.0
ruby_version = 1.8
ruby = $(topdir)/miniruby -I'$(topdir)' -I'$(top_srcdir)/lib' -I'$(extout)/$(arch)' -I'$(extout)/common' -I./- -I'$(top_srcdir)/ext' -rpurelib.rb
RUBY = $(ruby)
RM = rm -f
MAKEDIRS = mkdir -p
INSTALL = /usr/bin/install -c
INSTALL_PROG = $(INSTALL) -m 0755
INSTALL_DATA = $(INSTALL) -m 644
COPY = cp

#### End of system configuration section. ####

preload = 

libpath = . $(topdir)
LIBPATH =  -L. -L$(topdir)
DEFFILE = 

CLEANFILES = test/test.o
DISTCLEANFILES = call.func callback.func cbtable.func dlconfig.rb ./dlconfig.h test/libtest.so test/*~ *~ mkmf.log

extout = $(topdir)/.ext
extout_prefix = $(extout)$(target_prefix)/
target_prefix = 
LOCAL_LIBS = 
LIBS =  -ldl  -ldl -lobjc  
SRCS = dl.c handle.c ptr.c sym.c
OBJS = dl.o handle.o ptr.o sym.o
TARGET = dl
DLLIB = $(TARGET).bundle
EXTSTATIC = 
STATIC_LIB = $(TARGET).a

BINDIR        = $(extout)/bin
RUBYCOMMONDIR = $(extout)/common
RUBYLIBDIR    = $(RUBYCOMMONDIR)$(target_prefix)
RUBYARCHDIR   = $(extout)/$(arch)$(target_prefix)

TARGET_SO     = $(RUBYARCHDIR)/$(DLLIB)
CLEANLIBS     = $(RUBYARCHDIR)/$(TARGET).bundle $(RUBYARCHDIR)/$(TARGET).il? $(RUBYARCHDIR)/$(TARGET).tds $(RUBYARCHDIR)/$(TARGET).map
CLEANOBJS     = *.o *.a *.s[ol] *.pdb *.exp *.bak

all:		install
static:		$(STATIC_LIB) install-rb

clean:
		@-$(RM) $(CLEANLIBS) $(CLEANOBJS) $(CLEANFILES)

distclean:	clean
		@-$(RM) Makefile $(RUBY_EXTCONF_H) conftest.* mkmf.log
		@-$(RM) core ruby$(EXEEXT) *~ $(DISTCLEANFILES)

realclean:	distclean
install: install-so install-rb

install-so: $(RUBYARCHDIR)
install-so: $(RUBYARCHDIR)/$(DLLIB)
install-rb: pre-install-rb install-rb-default
install-rb-default: pre-install-rb-default
pre-install-rb: Makefile
pre-install-rb-default: Makefile
pre-install-rb-default: $(RUBYLIBDIR)/dl
install-rb-default: $(RUBYLIBDIR)/dl/import.rb
$(RUBYLIBDIR)/dl/import.rb: $(srcdir)/lib/dl/import.rb $(RUBYLIBDIR)/dl
	$(COPY) $(srcdir)/lib/dl/import.rb $(@D)
install-rb-default: $(RUBYLIBDIR)/dl/struct.rb
$(RUBYLIBDIR)/dl/struct.rb: $(srcdir)/lib/dl/struct.rb $(RUBYLIBDIR)/dl
	$(COPY) $(srcdir)/lib/dl/struct.rb $(@D)
install-rb-default: $(RUBYLIBDIR)/dl/types.rb
$(RUBYLIBDIR)/dl/types.rb: $(srcdir)/lib/dl/types.rb $(RUBYLIBDIR)/dl
	$(COPY) $(srcdir)/lib/dl/types.rb $(@D)
install-rb-default: $(RUBYLIBDIR)/dl/win32.rb
$(RUBYLIBDIR)/dl/win32.rb: $(srcdir)/lib/dl/win32.rb $(RUBYLIBDIR)/dl
	$(COPY) $(srcdir)/lib/dl/win32.rb $(@D)
pre-install-rb: $(RUBYARCHDIR)
install-rb: $(RUBYARCHDIR)/dlconfig.h
$(RUBYARCHDIR)/dlconfig.h: dlconfig.h $(RUBYARCHDIR)
	$(COPY) dlconfig.h $(@D)
install-rb: $(RUBYARCHDIR)/dl.h
$(RUBYARCHDIR)/dl.h: $(srcdir)/dl.h $(RUBYARCHDIR)
	$(COPY) $(srcdir)/dl.h $(@D)
$(RUBYLIBDIR)/dl:
	$(MAKEDIRS) $@
$(RUBYARCHDIR):
	$(MAKEDIRS) $@

site-install: site-install-so site-install-rb
site-install-so: install-so
site-install-rb: install-rb

.SUFFIXES: .c .m .cc .cxx .cpp .C .o

.cc.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.cxx.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.cpp.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.C.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.c.o:
	$(CC) $(INCFLAGS) $(CPPFLAGS) $(CFLAGS) -c $<

$(RUBYARCHDIR)/$(DLLIB): $(OBJS) Makefile
	@-$(RM) $@
	@-$(MAKEDIRS) $(@D)
	$(LDSHARED) -o $@ $(OBJS) $(LIBPATH) $(DLDFLAGS) $(LOCAL_LIBS) $(LIBS)

$(STATIC_LIB): $(OBJS)
	$(AR) cru $@ $(OBJS)
	@-ranlib $(DLLIB) 2> /dev/null || true

###
LDSHARED_TEST = $(LDSHARED) $(LDFLAGS) test/test.o -o test/libtest.so $(LOCAL_LIBS)

libtest.so: test/libtest.so

test/libtest.so: test/test.o $(srcdir)/test/libtest.def
	$(RUBY) -rftools -e 'ARGV.each do|d|File.mkpath(File.dirname(d))end' $@
	$(LDSHARED_TEST:dl.def=test/libtest.def)

test/test.o: $(srcdir)/test/test.c
	@$(RUBY) -rftools -e 'File.mkpath(*ARGV)' test
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $(srcdir)/test/test.c -o $@

test:: dl.so libtest.so force
	$(RUBY) -I. -I$(srcdir)/lib $(srcdir)/test/test.rb

force:

.PHONY: force test

allclean: distclean
	@rm -f $(CLEANFILES) $(DISTCLEANFILES)

$(OBJS): ./dlconfig.h

sym.o: dl.h call.func

dl.o: dl.h callback.func cbtable.func

ptr.o: dl.h

handle.o: dl.h

call.func: $(srcdir)/mkcall.rb ./dlconfig.rb
	@echo "Generating call.func"
	@$(RUBY) $(srcdir)/mkcall.rb > $@

callback.func: $(srcdir)/mkcallback.rb ./dlconfig.rb
	@echo "Generating callback.func"
	@$(RUBY) $(srcdir)/mkcallback.rb > $@

cbtable.func: $(srcdir)/mkcbtable.rb ./dlconfig.rb
	@echo "Generating cbtable.func"
	@$(RUBY) $(srcdir)/mkcbtable.rb > $@

debug:
	$(MAKE) CPPFLAGS="$(CPPFLAGS) -DDEBUG"
