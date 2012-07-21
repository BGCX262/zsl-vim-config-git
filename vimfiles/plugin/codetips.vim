
python << PYTHON_EOF

import os
import sys
import io
import ConfigParser
import vim
from copy import copy

path = os.path

sample_config = '''[default]
'''

def is_windows():
    return int(vim.eval('''has("win32") || has("win64") || has("win32unix")'''))

def search_files(pathitems, suffixes):
    ret = []
    for i in xrange(len(pathitems)):
        if pathitems[i] == "*":
            basedir = "/".join(pathitems[:i])
            if not path.isdir(basedir):
                return ret
            for d in os.listdir(basedir):
                if path.isdir(path.join(basedir, d)):
                    items = copy(pathitems)
                    items[i] = d
                    ret.extend(search_files(items, suffixes))
            return ret
        if pathitems[i] == "**":
            basedir = "/".join(pathitems[:i])
            if not path.isdir(basedir):
                return ret
            for root, dirs, files in os.walk(basedir):
                items = copy(pathitems)
                items[i] = path.relpath(root, basedir)
                ret.extend(search_files(items, suffixes))
            return ret
    if isinstance(suffixes, basestring):
        p = "/".join(pathitems) + "/" + suffixes
        if path.isfile(p):
            ret.append(p)
    else:
        basedir = "/".join(pathitems)
        if not path.isdir(basedir):
            return ret
        for f in os.listdir(basedir):
            pp = path.join(basedir, f)
            if ("*" in suffixes or path.splitext(pp)[1].lower() in suffixes) and path.isfile(pp):
                ret.append(path.normpath(pp))
    return ret

class basetips(object):
    def __init__(self):
        pass

    def set_default(self):
        self.suffixes = tuple(self.get_default_suffixes())
        self.paths = tuple(self.get_default_paths())
        self.tags = tuple(self.get_default_tags())

    def find_project_file(self):
        projname = "_project_" + self.get_file_type()
        cwd = vim.eval("getcwd()")
        temp = path.join(cwd, projname)
        while not path.isfile(temp):
            _cwd = path.dirname(cwd)
            if _cwd == cwd:
                return None
            cwd = _cwd
            temp = path.join(cwd, projname)
        return temp

    def parse_project_file(self, filename):
        config = ConfigParser.RawConfigParser()
        ret = {}
        if filename is not None:
            config.read(filename)
        else:
            config.readfp(io.BytesIO(sample_config))
        try:
            suffixes = config.get("default", "suffix").split(";")
        except (ConfigParser.NoOptionError, ConfigParser.NoSectionError):
            suffixes = self.get_default_suffixes()
        lstsuff = []
        for s in suffixes:
            if s == "$DEFAULT":
                lstsuff.extend(self.get_default_suffixes())
            else:
                lstsuff.append(s)
        ret["suffix"] = tuple(lstsuff)

        projectdir = path.dirname(filename) if filename else vim.eval("getcwd()")
        try:
            paths = config.get("default", "path").split(";")
        except (ConfigParser.NoOptionError, ConfigParser.NoSectionError):
            paths = ["."]
        ret["path"] = tuple(map(lambda p: path.normpath(path.join(projectdir, p)).replace("\\", "/") if not path.isabs(p) else p.replace("\\", "/"), paths))
        ret["projectdir"] = projectdir.replace("\\", "/")

        try:
            ret["debug"] = config.get("default", "debug")
        except (ConfigParser.NoOptionError, ConfigParser.NoSectionError):
            ret["debug"] = ""
        try:
            ret["cmdline"] = config.get("default", "cmdline")
        except (ConfigParser.NoOptionError, ConfigParser.NoSectionError):
            ret["cmdline"] = ""
        return ret

    def from_project_file(self):
        projectname = self.find_project_file()
        return self.parse_project_file(projectname)

    def get_default_paths(self):
        return ()

    def get_default_tags(self):
        return ()

    def get_default_cscopes(self):
        return ()

    def is_tags_supported(self):
        return True

    def is_cscope_supported(self):
        return True

    def set_vars(self, data):
        vim.command('let b:ct_suffix="%s"' % ",".join(data["suffix"]))
        vim.command('let b:ct_projectdir="%s"' % data["projectdir"])
        vim.command('let b:ct_path="%s"' % ','.join(data["path"])) 
        vim.command('let b:ct_debug="%s"' % data["debug"])
        vim.command('let b:ct_cmdline="%s"' % data["cmdline"])

    def init(self):
        data = self.from_project_file()
        self.set_vars(data)
        strsuff = ','.join(data['suffix'])
        vim.command("setlocal suffixes=%s" % strsuff)
        vim.command("setlocal suffixesadd=%s" % strsuff)
        vim.command("setlocal path=%s" % ','.join(list(data['path']) + list(self.get_default_paths())).replace("\\", "/"))
        if any(map(lambda p: path.isfile(path.join(data["projectdir"], p)), ["SConstruct", "Sconstruct", "sconstruct"])):
            vim.command("setlocal makeprg=scons")

        if self.is_tags_supported():
            self.add_tags()
        if self.is_cscope_supported():
            self.add_cscopes()

    def search_files(self, pathparrten, suffixes):
        ret = []
        items = pathparrten.replace("\\", "/").split("/")
        ret = search_files(items, suffixes)
        return tuple(set(ret))

    def add_tags(self):
        paths = [vim.eval("b:ct_projectdir")]
        paths.extend(self.get_default_paths())
        tagsfiles = []
        for p in paths:
            tagsfiles.extend(self.search_files(p, "_tags_" + self.get_file_type()))
        tagsfiles = list(set(tagsfiles))
        tagsfiles.extend(self.get_default_tags())
        vim.command("setlocal tags=%s" % ','.join(tagsfiles).replace("\\", "/"))

    def add_cscopes(self):
        paths = [vim.eval("b:ct_projectdir")]
        paths.extend(self.get_default_paths())
        cscopefiles = []
        for p in paths:
            cscopefiles.extend(self.search_files(p, "_cscope_" + self.get_file_type()))
        cscopefiles = list(set(cscopefiles))
        cscopefiles.extend(self.get_default_cscopes())
        for f in cscopefiles:
            vim.command("silent! cs add %s %s" % (f, path.dirname(f)))

    def make_cscope(self, inputfile, cscopefile):
        vim.command('silent! cs kill -1')
        origcwd = vim.eval('getcwd()')
        vim.command('lcd %s' % vim.eval("b:ct_projectdir"))
        os.system('cscope -b -f %s -i %s' % (cscopefile, inputfile))
        vim.command('lcd %s' % origcwd)

    def update_tags(self):
        suffixes = tuple(vim.eval("b:ct_suffix").split(","))
        files = []
        for p in vim.eval("b:ct_path").split(","):
            files.extend(self.search_files(p, suffixes))

        files = list(set(files))
        files.sort()
        projectdir = vim.eval("b:ct_projectdir")
        inputfile = path.join(projectdir, "_files_%s" % self.get_file_type()).replace("\\", "/")
        tagsfile = path.join(projectdir, "_tags_%s" % self.get_file_type()).replace("\\", "/")
        cscopefile = path.join(projectdir, "_cscope_%s" % self.get_file_type()).replace("\\", "/")
        with open(inputfile, 'w') as f:
            for name in files:
                f.write(path.relpath(name, projectdir).replace("\\", "/"))
                f.write("\n")

        if self.is_tags_supported():
            origcwd = vim.eval('getcwd()')
            vim.command('lcd %s' % projectdir)
            self.make_tags(inputfile, tagsfile)
            vim.command('lcd %s' % origcwd)
            self.add_tags()
        if self.is_cscope_supported():
            self.make_cscope(inputfile, cscopefile)
            self.add_cscopes()

class nulltips(object):
    def __init__(self, filetype):
        pass

    def init(self):
        vim.command('let b:ct_suffix=""')
        vim.command('let b:ct_projectdir="."')
        vim.command('let b:ct_path="."')
        vim.command('let b:ct_debug=""')
        vim.command('let b:ct_cmdline=""')
        vim.command('setl tags=tags;')

    def update_tags(self):
        pass

##-----------------------------------------------------------------------
class cpptips(basetips):
    def __init__(self):
        basetips.__init__(self)

    def get_file_type(self):
        return "cpp"

    def get_default_suffixes(self):
        return (".h", ".c", ".hpp", ".cpp", ".cc", ".cxx", ".hxx", ".hh", ".h++")

    def get_default_paths(self):
        ret = []
        iswin = is_windows()
        inc = os.environ.get("CPLUS_INCLUDE_PATH", None)
        if inc:
            ret += inc.split(";" if iswin else ":")
        if iswin:
            vimpath = vim.eval("$VIM")
            #ret.append(path.normpath(vimpath + "/../mingw/include"))
            #ret.append(path.normpath(vimpath + "/../mingw/lib/gcc/mingw32/4.6.2/inlcude/c++"))
            ret.append(path.normpath("D:/study/resource/software/devtools/Mingw/include"))
            ret.append(path.normpath(vimpath + "/vimfiles/cpp_src"))
        else:
            ret.append('/usr/include')
            ret.append('/usr/local/include')
        return ret

    def get_default_tags(self):
        return ()

    def make_tags(self, listfile, outfile):
        os.system('''ctags -L "%s" -f "%s" --c-kinds=+px --c++-kinds=+px --fields=+iaS --extra=+q --language-force=c++''' % (listfile, outfile))

class javatips(basetips):
    def __init__(self):
        basetips.__init__(self)

    def get_file_type(self):
        return "java"

    def get_default_suffixes(self):
        return (".java",)

    def make_tags(self, listfile, outfile):
        os.system('''ctags -L "%s" -f "%s" --fields=+iaS --extra=+q --language-force=java''' % (listfile, outfile))

class pythontips(basetips):
    def __init__(self):
        basetips.__init__(self)
        pp = os.environ.get("PYTHONPATH", None)
        if pp:
            self.pythonpath = tuple(pp.split(";" if is_windows() else ":"))
        else:
            self.pythonpath = ()

    def get_file_type(self):
        return "python"

    def get_default_suffixes(self):
        return (".py", ".pyw")

    def get_default_paths(self):
        ret = []
        ret.extend(self.pythonpath)
        if is_windows():
            ret.append(vim.eval("$VIM") + "/../Python27/Lib/**")
        return tuple(ret)

    def make_tags(self, listfile, outfile):
        lines = map(lambda l: l.strip(), open(listfile, 'r').readlines())
        orgcwd = vim.eval("getcwd()")
        vim.command("lcd %s" % path.dirname(listfile))
        os.system('ptags.py %s' % ' '.join(lines))
        if path.isfile(outfile):
            os.remove(outfile)
        os.rename("tags", path.basename(outfile))
        vim.command("lcd %s" % orgcwd)

    def is_cscope_supported(self):
        return False

#--------------------------------------------------------
def get_tips_instance(filetype):
    if filetype in ("c", "cpp"):
        return cpptips()
    elif filetype == "java":
        return javatips()
    elif filetype == "python":
        return pythontips()
    else:
        return nulltips(filetype)

def init_codetips():
    ft = vim.eval("&ft")
    get_tips_instance(ft).init()

def update_tags():
    ft = vim.eval("&ft")
    get_tips_instance(ft).update_tags()

def find_file_from_project():
    vim.command("FufFile %s/" % vim.eval("b:ct_projectdir"))

def find_all_file_from_project():
    vim.command("FufFile %s/**/" % vim.eval("b:ct_projectdir"))


def nodebug_run():
    dbg = vim.eval("b:ct_debug").replace("/", "\\")
    cmdline = vim.eval("b:ct_cmdline")
    prjdir = vim.eval("b:ct_projectdir")
    if not dbg:
        print >> sys.stderr, "do not know how to execute file"
    else:
        orgdir = vim.eval("getcwd()")
        vim.command("lcd " + prjdir)
        os.system('start "%s" cmd.exe /K %s %s' % (dbg, dbg, cmdline))
        vim.command("lcd " + orgdir)

def grep_search():
    _filelist = "%s/_files_%s" % (vim.eval("b:ct_projectdir"), get_tips_instance(vim.eval("&ft")).get_file_type())
    if not os.path.isfile(_filelist):
        print >> sys.stderr, "%s not found!" % _filelist
        return
    pattern = vim.eval('input("input pattern: ")')
    tmp = vim.eval("tempname()")
    tmpbat = vim.eval("tempname()") + ".bat"
    files = map(lambda l: '"' + vim.eval("b:ct_projectdir") + "/" + l + '"', filter(lambda l:l, map(lambda l: l.strip(), open(_filelist, "r"))))
    with open(tmpbat, "w") as f:
        print >> f, "@echo off"
        index = 0
        while index < len(files):
            print >> f, '''call grep -E -H -n "%s" %s''' % (pattern, ' '.join(files[index:index+50]))
            index += 40
    os.system('%s > %s' % (tmpbat, tmp))
    oldefm = vim.eval("&efm")
    vim.command("setl efm=%s" % vim.eval("&gfm").replace(" ", "\\ "))
    vim.command("cfile %s" % tmp)
    vim.command("setl efm=%s" % oldefm.replace(" ", "\\ "))
    os.remove(tmp)
    os.remove(tmpbat)

PYTHON_EOF


py init_codetips()
autocmd FileType * py init_codetips()
command UpdateTags :py update_tags()

function! MakeFile(cmd)
    let ct_cwdbackup = getcwd()
    execute "lcd ". b:ct_projectdir
    execute "make " . a:cmd
    execute "lcd " . ct_cwdbackup
endfunction


command Greps :py grep_search()
