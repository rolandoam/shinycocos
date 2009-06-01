require 'fileutils'
include FileUtils

RUBY_FILES = %w(
COPYING
README
GPL
LEGAL
LGPL
array.c
enc/ascii.c
enc/big5.c
bignum.c
ext/syck/bytecode.c
class.c
compar.c
compile.c
complex.c
cont.c
enc/cp949.c
debug.c
dir.c
dln.c
dmydln.c
dmyencoding.c
dmyext.c
ext/syck/emitter.c
enc/encdb.c
enum.c
enumerator.c
error.c
enc/euc_jp.c
eval.c
file.c
missing/finite.c
gc.c
ext/syck/gram.c
ext/syck/gram.h
ext/syck/handler.c
hash.c
ext/syck/implicit.c
inits.c
io.c
iseq.c
missing/lgamma_r.c
load.c
marshal.c
math.c
newline.c
ext/syck/node.c
numeric.c
object.c
pack.c
parse.c
prelude.c
proc.c
process.c
random.c
range.c
rational.c
re.c
regcomp.c
regenc.c
regerror.c
regexec.c
regparse.c
regsyntax.c
ruby.c
ext/syck/rubyext.c
safe.c
enc/shift_jis.c
signal.c
sprintf.c
st.c
strftime.c
string.c
ext/stringio/stringio.c
ext/strscan/strscan.c
struct.c
ext/syck/syck.c
ext/syck/syck.h
thread.c
time.c
ext/syck/token.c
transcode.c
enc/unicode.c
enc/us_ascii.c
enc/utf_16be.c
enc/utf_32be.c
enc/utf_8.c
util.c
variable.c
version.c
vm.c
vm_dump.c
ext/syck/yaml2byte.c
ext/syck/yamlbyte.h
ext/zlib/zlib.c
)

# headers
RUBY_FILES.concat %w(
debug.h
dln.h
encdb.h
eval_intern.h
gc.h
id.h
iseq.h
node.h
parse.h
regenc.h
regint.h
regparse.h
revision.h
thread_pthread.h
thread_win32.h
transcode_data.h
transdb.h
version.h
vm_core.h
vm_exec.h
vm_insnhelper.h
vm_opts.h
include
)

# include files
RUBY_FILES.concat %w(
insns.inc
insns_info.inc
known_errors.inc
node_name.inc
opt_sc.inc
optinsn.inc
optunifs.inc
vm.inc
vmtc.inc
eval_error.c
eval_jump.c
id.c
lex.c
missing/vsnprintf.c
thread_pthread.c
vm_insnhelper.c
vm_exec.c
vm_eval.c
vm_method.c
encoding.c
)

rm_r "ruby"
mkdir_p "ruby"
RUBY_FILES.each { |file|
  fname = File.basename(file)
  if (dir = File.dirname(file)) != "."
    mkdir_p "ruby/#{dir}"
  end
  cp_r "ruby_svn/#{file}", "ruby/#{dir}/#{fname}"
}
