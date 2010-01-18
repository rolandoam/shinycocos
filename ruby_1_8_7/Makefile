SHELL = /bin/sh
NULLCMD = :

#### Start of system configuration section. ####

srcdir = .
VPATH = $(srcdir)/missing

CC = gcc
YACC = bison -y
PURIFY =
AUTOCONF = autoconf

MKFILES = Makefile

prefix = /usr/local
exec_prefix = ${prefix}
bindir = ${exec_prefix}/bin
sbindir = ${exec_prefix}/sbin
libdir = ${exec_prefix}/lib
libexecdir = ${exec_prefix}/libexec
datarootdir = ${prefix}/share
datadir = ${datarootdir}
arch = i686-darwin9.8.0
sitearch = i686-darwin9.8.0
sitedir = ${libdir}/ruby/site_ruby

TESTUI = console
TESTS =
RDOCTARGET = 

EXTOUT = .ext
RIDATADIR = $(DESTDIR)$(datadir)/ri/$(MAJOR).$(MINOR)/system

empty =
OUTFLAG = -o $(empty)
CFLAGS = -g -O2 -pipe -fno-common ${cflags}  -DRUBY_EXPORT 
cflags = ${optflags} ${debugflags}
optflags = 
debugflags = 
CPPFLAGS = -I. -I$(srcdir)  -D_XOPEN_SOURCE -D_DARWIN_C_SOURCE $(DEFS) ${cppflags}
LDFLAGS =  $(CFLAGS) -L. 
EXTLDFLAGS = 
XLDFLAGS =  $(EXTLDFLAGS)
EXTLIBS = 
LIBS = -ldl -lobjc  $(EXTLIBS)
MISSING =  
LDSHARED = cc -dynamic -bundle -undefined suppress -flat_namespace
DLDFLAGS =  $(EXTLDFLAGS) 
SOLIBS = 
MAINLIBS = 
MINIOBJS = dmydln.o

RUBY_INSTALL_NAME=ruby
RUBY_SO_NAME=$(RUBY_INSTALL_NAME)
EXEEXT = 
PROGRAM=$(RUBY_INSTALL_NAME)$(EXEEXT)
RUBY = $(RUBY_INSTALL_NAME)
MINIRUBY = ./miniruby$(EXEEXT) -I$(srcdir)/lib -I$(EXTOUT)/common -I./- -r$(srcdir)/ext/purelib.rb $(MINIRUBYOPT)
RUNRUBY = $(MINIRUBY) $(srcdir)/runruby.rb --extout=$(EXTOUT) $(RUNRUBYOPT) --

#### End of system configuration section. ####

MAJOR=	1
MINOR=	8
TEENY=	7

LIBRUBY_A     = lib$(RUBY_SO_NAME)-static.a
LIBRUBY_SO    = lib$(RUBY_SO_NAME).so.$(MAJOR).$(MINOR).$(TEENY)
LIBRUBY_ALIASES= lib$(RUBY_SO_NAME).so
LIBRUBY	      = $(LIBRUBY_A)
LIBRUBYARG    = $(LIBRUBYARG_STATIC)
LIBRUBYARG_STATIC = -l$(RUBY_SO_NAME)-static
LIBRUBYARG_SHARED = 

PREP          = miniruby$(EXEEXT)
ARCHFILE      = 
SETUP         =
EXTSTATIC     = 

RM            = rm -f
NM            = 
AR            = ar
ARFLAGS       = rcu
RANLIB        = ranlib
AS            = as
ASFLAGS       = 

OBJEXT        = o
MANTYPE	      = doc

INSTALLED_LIST= .installed.list
#### End of variables

all:

.DEFAULT: all

# Prevent GNU make v3 from overflowing arg limit on SysV.
.NOEXPORT:

miniruby$(EXEEXT):
		@$(RM) $@
		$(PURIFY) $(CC) $(LDFLAGS) $(XLDFLAGS) $(MAINLIBS) $(MAINOBJ) $(MINIOBJS) $(LIBRUBY_A) $(LIBS) $(OUTFLAG)$@

$(PROGRAM):
		@$(RM) $@
		$(PURIFY) $(CC) $(LDFLAGS) $(XLDFLAGS) $(MAINLIBS) $(MAINOBJ) $(EXTOBJS) $(LIBRUBYARG) $(LIBS) $(OUTFLAG)$@

# We must `rm' the library each time this rule is invoked because "updating" a
# MAB library on Apple/NeXT (see --enable-fat-binary in configure) is not
# supported.
$(LIBRUBY_A):
		@$(RM) $@
		$(AR) $(ARFLAGS) $@ $(OBJS) $(DMYEXT)
		@-$(RANLIB) $@ 2> /dev/null || true

$(LIBRUBY_SO):
		@-$(PRE_LIBRUBY_UPDATE)
		$(LDSHARED) $(DLDFLAGS) $(OBJS) $(DLDOBJS) $(SOLIBS) $(OUTFLAG)$@
		@-$(MINIRUBY) -e 'ARGV.each{|link| File.delete link if File.exist? link; \
						  File.symlink "$(LIBRUBY_SO)", link}' \
				$(LIBRUBY_ALIASES) || true

fake.rb:	Makefile
		@echo ' \
		class Object; \
		  CROSS_COMPILING = RUBY_PLATFORM; \
		  remove_const :RUBY_PLATFORM; \
		  remove_const :RUBY_VERSION; \
		  RUBY_PLATFORM = "i686-darwin9.8.0"; \
		  RUBY_VERSION = "1.8.7"; \
		end; \
		if RUBY_PLATFORM =~ /mswin|bccwin|mingw/; \
		  class File; \
		    remove_const :ALT_SEPARATOR; \
		    ALT_SEPARATOR = "\\"; \
		  end; \
		end; \
		' > $@

Makefile:	$(srcdir)/Makefile.in

$(MKFILES): config.status $(srcdir)/common.mk
		MAKE=$(MAKE) $(SHELL) ./config.status
		@{ \
		    echo "all:; -@rm -f conftest.mk"; \
		    echo "conftest.mk: .force; @echo AUTO_REMAKE"; \
		    echo ".force:"; \
		} > conftest.mk || exit 1; \
		$(MAKE) -f conftest.mk | grep '^AUTO_REMAKE$$' >/dev/null 2>&1 || \
		{ echo "Makefile updated, restart."; exit 1; }

config.status:	$(srcdir)/configure
		MINIRUBY="$(MINIRUBY)" $(SHELL) ./config.status --recheck

$(srcdir)/configure: $(srcdir)/configure.in
		cd $(srcdir) && $(AUTOCONF)

lex.c: keywords
	( gperf -C -p -j1 -i 1 -g -o -t -N rb_reserved_word -k1,3,$$ $? > $@.tmp && mv $@.tmp $@ ) || \
	if test -f $@; then \
	  touch $@ && echo $@ touched.; \
	else \
	  cp $(srcdir)/lex.c $@ && echo $@ copied.; \
	fi

.y.c:
	$(YACC) $<
	sed '/^#/s|y\.tab\.c|$@|' y.tab.c > $@
	rm -f y.tab.c

.c.o:
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $<

.s.o:
	$(AS) $(ASFLAGS) -o $@ $<

clean-local::
	@$(RM) ext/extinit.c ext/extinit.$(OBJEXT)

distclean-local::
	@$(RM) ext/config.cache $(RBCONFIG)

ext/extinit.$(OBJEXT): ext/extinit.c $(SETUP)
	$(CC) $(CFLAGS) $(XCFLAGS) $(CPPFLAGS) $(OUTFLAG)$@ -c ext/extinit.c

update-rubyspec: 
	if [ -d $(srcdir)/rubyspec ]; then \
	  cd $(srcdir)/rubyspec/mspec; \
	  git pull; \
	  cd ../spec; \
	  git pull; \
	else \
	  mkdir $(srcdir)/rubyspec; \
	  git clone $(MSPEC_GIT_URL) $(srcdir)/rubyspec/mspec; \
	  git clone $(RUBYSPEC_GIT_URL) $(srcdir)/rubyspec/spec; \
	fi

test-rubyspec:
	@if [ ! -d $(srcdir)/rubyspec ]; then echo No rubyspec here.  make update-rubyspec first.; exit 1; fi
	RUBY_EXE="$(RUNRUBY)" $(RUNRUBY) $(srcdir)/rubyspec/mspec/bin/mspec-run --background --prefix $(srcdir)/rubyspec/spec -B $(srcdir)/rubyspec/spec/ruby.$(MAJOR).$(MINOR).mspec

bin: $(PROGRAM) $(WPROGRAM)
lib: $(LIBRUBY)
dll: $(LIBRUBY_SO)

RUBYLIB       = -
RUBYOPT       = -

SPEC_GIT_BASE = git://github.com/rubyspec
MSPEC_GIT_URL = $(SPEC_GIT_BASE)/mspec.git
RUBYSPEC_GIT_URL = $(SPEC_GIT_BASE)/rubyspec.git

STATIC_RUBY   = static-ruby

EXTCONF       = extconf.rb
RBCONFIG      = ./.rbconfig.time
LIBRUBY_EXTS  = ./.libruby-with-ext.time
RDOCOUT       = $(EXTOUT)/rdoc

DMYEXT	      = dmyext.$(OBJEXT)
MAINOBJ	      = main.$(OBJEXT)
EXTOBJS	      = 
DLDOBJS	      = $(DMYEXT)

OBJS	      = array.$(OBJEXT) \
		bignum.$(OBJEXT) \
		class.$(OBJEXT) \
		compar.$(OBJEXT) \
		dir.$(OBJEXT) \
		dln.$(OBJEXT) \
		enum.$(OBJEXT) \
		enumerator.$(OBJEXT) \
		error.$(OBJEXT) \
		eval.$(OBJEXT) \
		file.$(OBJEXT) \
		gc.$(OBJEXT) \
		hash.$(OBJEXT) \
		inits.$(OBJEXT) \
		io.$(OBJEXT) \
		marshal.$(OBJEXT) \
		math.$(OBJEXT) \
		numeric.$(OBJEXT) \
		object.$(OBJEXT) \
		pack.$(OBJEXT) \
		parse.$(OBJEXT) \
		process.$(OBJEXT) \
		prec.$(OBJEXT) \
		random.$(OBJEXT) \
		range.$(OBJEXT) \
		re.$(OBJEXT) \
		regex.$(OBJEXT) \
		ruby.$(OBJEXT) \
		signal.$(OBJEXT) \
		sprintf.$(OBJEXT) \
		st.$(OBJEXT) \
		string.$(OBJEXT) \
		struct.$(OBJEXT) \
		time.$(OBJEXT) \
		util.$(OBJEXT) \
		variable.$(OBJEXT) \
		version.$(OBJEXT) \
		$(MISSING)

SCRIPT_ARGS   =	--dest-dir="$(DESTDIR)" \
		--extout="$(EXTOUT)" \
		--mflags="$(MFLAGS)" \
		--make-flags="$(MAKEFLAGS)"
EXTMK_ARGS    =	$(SCRIPT_ARGS) --extension $(EXTS) --extstatic $(EXTSTATIC) \
		--make-flags="MINIRUBY='$(MINIRUBY)'" --
INSTRUBY_ARGS =	$(SCRIPT_ARGS) \
		--data-mode=$(INSTALL_DATA_MODE) \
		--prog-mode=$(INSTALL_PROG_MODE) \
		--installed-list $(INSTALLED_LIST)
INSTALL_PROG_MODE = 0755
INSTALL_DATA_MODE = 0644

PRE_LIBRUBY_UPDATE = $(MINIRUBY) -e 'ARGV[1] or File.unlink(ARGV[0]) rescue nil' -- \
			$(LIBRUBY_EXTS) $(LIBRUBY_SO_UPDATE)

TESTSDIR      = $(srcdir)/test
TESTWORKDIR   = testwork

all: $(MKFILES) $(PREP) $(RBCONFIG) $(LIBRUBY)
	@$(MINIRUBY) $(srcdir)/ext/extmk.rb --make="$(MAKE)" $(EXTMK_ARGS)
prog: $(PROGRAM) $(WPROGRAM)

miniruby$(EXEEXT): config.status $(LIBRUBY_A) $(MAINOBJ) $(MINIOBJS) $(OBJS) $(DMYEXT)

$(PROGRAM): $(LIBRUBY) $(MAINOBJ) $(OBJS) $(EXTOBJS) $(SETUP) $(PREP)

$(LIBRUBY_A):	$(OBJS) $(DMYEXT) $(ARCHFILE)

$(LIBRUBY_SO):	$(OBJS) $(DLDOBJS) $(LIBRUBY_A) $(PREP) $(LIBRUBY_SO_UPDATE)

$(LIBRUBY_EXTS):
	@exit > $@

$(STATIC_RUBY)$(EXEEXT): $(MAINOBJ) $(DLDOBJS) $(EXTOBJS) $(LIBRUBY_A)
	@$(RM) $@
	$(PURIFY) $(CC) $(MAINOBJ) $(DLDOBJS) $(EXTOBJS) $(LIBRUBY_A) $(MAINLIBS) $(EXTLIBS) $(LIBS) $(OUTFLAG)$@ $(LDFLAGS) $(XLDFLAGS)

ruby.imp: $(OBJS)
	@$(NM) -Pgp $(OBJS) | awk 'BEGIN{print "#!"}; $$2~/^[BD]$$/{print $$1}' | sort -u -o $@

install: install-nodoc $(RDOCTARGET)
install-all: install-nodoc install-doc

install-nodoc: pre-install-nodoc do-install-nodoc post-install-nodoc
pre-install-nodoc:: pre-install-local pre-install-ext
do-install-nodoc: 
	$(MINIRUBY) $(srcdir)/instruby.rb --make="$(MAKE)" $(INSTRUBY_ARGS) --mantype="$(MANTYPE)"
post-install-nodoc:: post-install-local post-install-ext

install-local: pre-install-local do-install-local post-install-local
pre-install-local:: pre-install-bin pre-install-lib pre-install-man
do-install-local:
	$(MINIRUBY) $(srcdir)/instruby.rb --make="$(MAKE)" $(INSTRUBY_ARGS) --install=local --mantype="$(MANTYPE)"
loadpath: $(PREP)
	$(MINIRUBY) -e 'p $$:'

post-install-local:: post-install-bin post-install-lib post-install-man

install-ext: pre-install-ext do-install-ext post-install-ext
pre-install-ext:: pre-install-ext-arch pre-install-ext-comm
do-install-ext:
	$(MINIRUBY) $(srcdir)/instruby.rb --make="$(MAKE)" $(INSTRUBY_ARGS) --install=ext
post-install-ext:: post-install-ext-arch post-install-ext-comm

install-arch: pre-install-arch do-install-arch post-install-arch
pre-install-arch:: pre-install-bin pre-install-ext-arch
do-install-arch:
	$(MINIRUBY) $(srcdir)/instruby.rb --make="$(MAKE)" $(INSTRUBY_ARGS) --install=bin --install=ext-arch
post-install-arch:: post-install-bin post-install-ext-arch

install-comm: pre-install-comm do-install-comm post-install-comm
pre-install-comm:: pre-install-lib pre-install-ext-comm pre-install-man
do-install-comm:
	$(MINIRUBY) $(srcdir)/instruby.rb --make="$(MAKE)" $(INSTRUBY_ARGS) --install=lib --install=ext-comm --install=man
post-install-comm:: post-install-lib post-install-ext-comm post-install-man

install-bin: pre-install-bin do-install-bin post-install-bin
pre-install-bin:: install-prereq
do-install-bin:
	$(MINIRUBY) $(srcdir)/instruby.rb --make="$(MAKE)" $(INSTRUBY_ARGS) --install=bin
post-install-bin::
	@$(NULLCMD)

install-lib: pre-install-lib do-install-lib post-install-lib
pre-install-lib:: install-prereq
do-install-lib:
	$(MINIRUBY) $(srcdir)/instruby.rb --make="$(MAKE)" $(INSTRUBY_ARGS) --install=lib
post-install-lib::
	@$(NULLCMD)

install-ext-comm: pre-install-ext-comm do-install-ext-comm post-install-ext-comm
pre-install-ext-comm:: install-prereq
do-install-ext-comm:
	$(MINIRUBY) $(srcdir)/instruby.rb --make="$(MAKE)" $(INSTRUBY_ARGS) --install=ext-comm
post-install-ext-comm::
	@$(NULLCMD)

install-ext-arch: pre-install-ext-arch do-install-ext-arch post-install-ext-arch
pre-install-ext-arch:: install-prereq
do-install-ext-arch:
	$(MINIRUBY) $(srcdir)/instruby.rb --make="$(MAKE)" $(INSTRUBY_ARGS) --install=ext-arch
post-install-ext-arch::
	@$(NULLCMD)

install-man: pre-install-man do-install-man post-install-man
pre-install-man:: install-prereq
do-install-man:
	$(MINIRUBY) $(srcdir)/instruby.rb --make="$(MAKE)" $(INSTRUBY_ARGS) --install=man --mantype="$(MANTYPE)"
post-install-man::
	@$(NULLCMD)

what-where: no-install
no-install: no-install-nodoc no-install-doc
what-where-all: no-install-all
no-install-all: no-install-nodoc

what-where-nodoc: no-install-nodoc
no-install-nodoc: pre-no-install-nodoc dont-install-nodoc post-no-install-nodoc
pre-no-install-nodoc:: pre-no-install-local pre-no-install-ext
dont-install-nodoc: 
	$(MINIRUBY) $(srcdir)/instruby.rb -n --make="$(MAKE)" $(INSTRUBY_ARGS) --mantype="$(MANTYPE)"
post-no-install-nodoc:: post-no-install-local post-no-install-ext

what-where-local: no-install-local
no-install-local: pre-no-install-local dont-install-local post-no-install-local
pre-no-install-local:: pre-no-install-bin pre-no-install-lib pre-no-install-man
dont-install-local:
	$(MINIRUBY) $(srcdir)/instruby.rb -n --make="$(MAKE)" $(INSTRUBY_ARGS) --install=local --mantype="$(MANTYPE)"
post-no-install-local:: post-no-install-bin post-no-install-lib post-no-install-man

what-where-ext: no-install-ext
no-install-ext: pre-no-install-ext dont-install-ext post-no-install-ext
pre-no-install-ext:: pre-no-install-ext-arch pre-no-install-ext-comm
dont-install-ext:
	$(MINIRUBY) $(srcdir)/instruby.rb -n --make="$(MAKE)" $(INSTRUBY_ARGS) --install=ext
post-no-install-ext:: post-no-install-ext-arch post-no-install-ext-comm

what-where-arch: no-install-arch
no-install-arch: pre-no-install-arch dont-install-arch post-no-install-arch
pre-no-install-arch:: pre-no-install-bin pre-no-install-ext-arch
dont-install-arch:
	$(MINIRUBY) $(srcdir)/instruby.rb -n --make="$(MAKE)" $(INSTRUBY_ARGS) --install=bin --install=ext-arch
post-no-install-arch:: post-no-install-lib post-no-install-man post-no-install-ext-arch

what-where-comm: no-install-comm
no-install-comm: pre-no-install-comm dont-install-comm post-no-install-comm
pre-no-install-comm:: pre-no-install-lib pre-no-install-ext-comm pre-no-install-man
dont-install-comm:
	$(MINIRUBY) $(srcdir)/instruby.rb -n --make="$(MAKE)" $(INSTRUBY_ARGS) --install=lib --install=ext-comm --install=man
post-no-install-comm:: post-no-install-lib post-no-install-ext-comm post-no-install-man

what-where-bin: no-install-bin
no-install-bin: pre-no-install-bin dont-install-bin post-no-install-bin
pre-no-install-bin:: install-prereq
dont-install-bin:
	$(MINIRUBY) $(srcdir)/instruby.rb -n --make="$(MAKE)" $(INSTRUBY_ARGS) --install=bin
post-no-install-bin::
	@$(NULLCMD)

what-where-lib: no-install-lib
no-install-lib: pre-no-install-lib dont-install-lib post-no-install-lib
pre-no-install-lib:: install-prereq
dont-install-lib:
	$(MINIRUBY) $(srcdir)/instruby.rb -n --make="$(MAKE)" $(INSTRUBY_ARGS) --install=lib
post-no-install-lib::
	@$(NULLCMD)

what-where-ext-comm: no-install-ext-comm
no-install-ext-comm: pre-no-install-ext-comm dont-install-ext-comm post-no-install-ext-comm
pre-no-install-ext-comm:: install-prereq
dont-install-ext-comm:
	$(MINIRUBY) $(srcdir)/instruby.rb -n --make="$(MAKE)" $(INSTRUBY_ARGS) --install=ext-comm
post-no-install-ext-comm::
	@$(NULLCMD)

what-where-ext-arch: no-install-ext-arch
no-install-ext-arch: pre-no-install-ext-arch dont-install-ext-arch post-no-install-ext-arch
pre-no-install-ext-arch:: install-prereq
dont-install-ext-arch:
	$(MINIRUBY) $(srcdir)/instruby.rb -n --make="$(MAKE)" $(INSTRUBY_ARGS) --install=ext-arch
post-no-install-ext-arch::
	@$(NULLCMD)

what-where-man: no-install-man
no-install-man: pre-no-install-man dont-install-man post-no-install-man
pre-no-install-man:: install-prereq
dont-install-man:
	$(MINIRUBY) $(srcdir)/instruby.rb -n --make="$(MAKE)" $(INSTRUBY_ARGS) --install=man --mantype="$(MANTYPE)"
post-no-install-man::
	@$(NULLCMD)

install-doc: rdoc pre-install-doc do-install-doc post-install-doc
pre-install-doc:: install-prereq
do-install-doc: $(PROGRAM)
	$(MINIRUBY) $(srcdir)/instruby.rb --make="$(MAKE)" $(INSTRUBY_ARGS) --install=rdoc --rdoc-output="$(RDOCOUT)"
post-install-doc::
	@$(NULLCMD)

rdoc: $(PROGRAM) PHONY
	@echo Generating RDoc documentation
	$(RUNRUBY) "$(srcdir)/bin/rdoc" --all --ri --op "$(RDOCOUT)" "$(srcdir)"

what-where-doc: no-install-doc
no-install-doc: pre-no-install-doc dont-install-doc post-no-install-doc
pre-no-install-doc:: install-prereq
dont-install-doc::
	$(MINIRUBY) $(srcdir)/instruby.rb -n --make="$(MAKE)" $(INSTRUBY_ARGS) --install=rdoc --rdoc-output="$(RDOCOUT)"
post-no-install-doc::
	@$(NULLCMD)

CLEAR_INSTALLED_LIST = clear-installed-list

install-prereq: $(CLEAR_INSTALLED_LIST)

clear-installed-list:
	@exit > $(INSTALLED_LIST)

clean: clean-ext clean-local
clean-local::
	@$(RM) $(OBJS) $(MINIOBJS) $(MAINOBJ) $(LIBRUBY_A) $(LIBRUBY_SO) $(LIBRUBY) $(LIBRUBY_ALIASES)
	@$(RM) $(PROGRAM) $(WPROGRAM) miniruby$(EXEEXT) dmyext.$(OBJEXT) $(ARCHFILE) .*.time
	@$(RM) y.tab.c y.output
clean-ext:
	@-$(MINIRUBY) $(srcdir)/ext/extmk.rb --make="$(MAKE)" $(EXTMK_ARGS) clean

distclean: distclean-ext distclean-local
distclean-local:: clean-local
	@$(RM) $(MKFILES) config.h rbconfig.rb
	@$(RM) config.cache config.log config.status
	@$(RM) *~ *.bak *.stackdump core *.core gmon.out $(PREP)
distclean-ext:
	@-$(MINIRUBY) $(srcdir)/ext/extmk.rb --make="$(MAKE)" $(EXTMK_ARGS) distclean

realclean:: realclean-ext realclean-local
realclean-local:: distclean-local
	@$(RM) parse.c lex.c
realclean-ext::
	@-$(MINIRUBY) $(srcdir)/ext/extmk.rb --make="$(MAKE)" $(EXTMK_ARGS) realclean

check: test test-all

test: miniruby$(EXEEXT) $(RBCONFIG) $(PROGRAM) PHONY
	@$(MINIRUBY) $(srcdir)/rubytest.rb

test-all:
	$(RUNRUBY) "$(srcdir)/test/runner.rb" --basedir="$(TESTSDIR)" --runner=$(TESTUI) $(TESTS)

extconf:
	$(MINIRUBY) -run -e mkdir -- -p "$(EXTCONFDIR)"
	$(RUNRUBY) -C "$(EXTCONFDIR)" $(EXTCONF) $(EXTCONFARGS)

$(RBCONFIG): $(srcdir)/mkconfig.rb config.status $(PREP)
	@$(MINIRUBY) $(srcdir)/mkconfig.rb -timestamp=$@ \
		-install_name=$(RUBY_INSTALL_NAME) \
		-so_name=$(RUBY_SO_NAME) rbconfig.rb

.PRECIOUS: $(MKFILES)

.PHONY: test install install-nodoc install-doc dist

PHONY:

parse.c: parse.y

acosh.$(OBJEXT): acosh.c
alloca.$(OBJEXT): alloca.c
crypt.$(OBJEXT): crypt.c
dup2.$(OBJEXT): dup2.c
erf.$(OBJEXT): erf.c
finite.$(OBJEXT): finite.c
flock.$(OBJEXT): flock.c
memcmp.$(OBJEXT): memcmp.c
memmove.$(OBJEXT): memmove.c
mkdir.$(OBJEXT): mkdir.c
vsnprintf.$(OBJEXT): vsnprintf.c
strcasecmp.$(OBJEXT): strcasecmp.c
strncasecmp.$(OBJEXT): strncasecmp.c
strchr.$(OBJEXT): strchr.c
strdup.$(OBJEXT): strdup.c
strerror.$(OBJEXT): strerror.c
strftime.$(OBJEXT): strftime.c
strstr.$(OBJEXT): strstr.c
strtod.$(OBJEXT): strtod.c
strtol.$(OBJEXT): strtol.c
strtoul.$(OBJEXT): strtoul.c
nt.$(OBJEXT): nt.c
x68.$(OBJEXT): x68.c
os2.$(OBJEXT): os2.c
dl_os2.$(OBJEXT): dl_os2.c
ia64.$(OBJEXT): ia64.s
	$(CC) $(CFLAGS) -c $<

# when I use -I., there is confliction at "OpenFile" 
# so, set . into environment varible "include"
win32.$(OBJEXT): win32.c

###

array.$(OBJEXT): array.c ruby.h config.h \
  defines.h intern.h missing.h \
  util.h st.h
bignum.$(OBJEXT): bignum.c ruby.h config.h \
  defines.h intern.h missing.h \
  rubysig.h
class.$(OBJEXT): class.c ruby.h config.h \
  defines.h intern.h missing.h \
  rubysig.h node.h st.h
compar.$(OBJEXT): compar.c ruby.h config.h \
  defines.h intern.h missing.h
dir.$(OBJEXT): dir.c ruby.h config.h \
  defines.h intern.h missing.h \
  util.h
dln.$(OBJEXT): dln.c ruby.h config.h \
  defines.h intern.h missing.h \
  dln.h
dmydln.$(OBJEXT): dmydln.c dln.$(OBJEXT)
dmyext.$(OBJEXT): dmyext.c
enum.$(OBJEXT): enum.c ruby.h config.h \
  defines.h intern.h missing.h \
  node.h util.h
enumerator.$(OBJEXT): enumerator.c ruby.h config.h \
  defines.h intern.h missing.h
error.$(OBJEXT): error.c ruby.h config.h \
  defines.h intern.h missing.h \
  env.h st.h
eval.$(OBJEXT): eval.c ruby.h config.h \
  defines.h intern.h missing.h \
  node.h env.h util.h \
  rubysig.h st.h dln.h
file.$(OBJEXT): file.c ruby.h config.h \
  defines.h intern.h missing.h \
  rubyio.h rubysig.h util.h \
  dln.h
gc.$(OBJEXT): gc.c ruby.h config.h \
  defines.h intern.h missing.h \
  rubysig.h st.h node.h \
  env.h re.h regex.h
hash.$(OBJEXT): hash.c ruby.h config.h \
  defines.h intern.h missing.h \
  st.h util.h rubysig.h
inits.$(OBJEXT): inits.c ruby.h config.h \
  defines.h intern.h missing.h
io.$(OBJEXT): io.c ruby.h config.h \
  defines.h intern.h missing.h \
  rubyio.h rubysig.h  util.h \
  env.h
main.$(OBJEXT): main.c ruby.h config.h \
  defines.h intern.h missing.h
marshal.$(OBJEXT): marshal.c ruby.h config.h \
  defines.h intern.h missing.h \
  rubyio.h st.h util.h
math.$(OBJEXT): math.c ruby.h config.h \
  defines.h intern.h missing.h
numeric.$(OBJEXT): numeric.c ruby.h config.h \
  env.h defines.h intern.h \
  missing.h
object.$(OBJEXT): object.c ruby.h config.h \
  defines.h intern.h missing.h \
  st.h util.h
pack.$(OBJEXT): pack.c ruby.h config.h \
  defines.h intern.h missing.h
parse.$(OBJEXT): parse.c ruby.h config.h \
  defines.h intern.h missing.h \
  env.h node.h st.h \
  regex.h util.h lex.c
prec.$(OBJEXT): prec.c ruby.h config.h \
  defines.h intern.h missing.h
process.$(OBJEXT): process.c ruby.h config.h \
  defines.h intern.h missing.h \
  rubysig.h st.h
random.$(OBJEXT): random.c ruby.h config.h \
  defines.h intern.h missing.h
range.$(OBJEXT): range.c ruby.h config.h \
  defines.h intern.h missing.h
re.$(OBJEXT): re.c ruby.h config.h \
  defines.h intern.h missing.h \
  re.h regex.h
regex.$(OBJEXT): regex.c config.h regex.h
ruby.$(OBJEXT): ruby.c ruby.h config.h \
  defines.h intern.h missing.h \
  dln.h node.h util.h
signal.$(OBJEXT): signal.c ruby.h config.h \
  defines.h intern.h missing.h \
  rubysig.h
sprintf.$(OBJEXT): sprintf.c ruby.h config.h \
  defines.h intern.h missing.h
st.$(OBJEXT): st.c config.h st.h
string.$(OBJEXT): string.c ruby.h config.h \
  defines.h intern.h missing.h \
  re.h regex.h
struct.$(OBJEXT): struct.c ruby.h config.h \
  defines.h intern.h missing.h
time.$(OBJEXT): time.c ruby.h config.h \
  defines.h intern.h missing.h
util.$(OBJEXT): util.c ruby.h config.h \
  defines.h intern.h missing.h \
  util.h
variable.$(OBJEXT): variable.c ruby.h config.h \
  defines.h intern.h missing.h \
  env.h node.h st.h util.h
version.$(OBJEXT): version.c ruby.h config.h \
  defines.h intern.h missing.h \
  version.h

dist: $(PROGRAM)
	$(RUNRUBY) $(srcdir)/distruby.rb
