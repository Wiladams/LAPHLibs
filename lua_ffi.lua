local ffi = require "ffi"
local C = ffi.C
local cdef = ffi.cdef

local bit = require "bit"
local lshift = bit.lshift


local luajit = ffi.load("lua51")

--[=====================[
	FROM luaconf.H
--]=====================]

-- Default path for loading Lua and C modules with require().
if ffi.abi("win") then
--[[
 In Windows, any exclamation mark ('!') in the path is replaced by the
 path of the directory of the executable file of the current process.
--]]
	LUA_LDIR	= "!\\lua\\"
	LUA_CDIR	= "!\\"
	LUA_PATH_DEFAULT = ".\\?.lua;"..LUA_LDIR.."?.lua;"..LUA_LDIR.."?\\init.lua;"
	LUA_CPATH_DEFAULT = ".\\?.dll;"..LUA_CDIR.."?.dll;"..LUA_CDIR.."loadall.dll"
else
	LUA_ROOT	= "/usr/local/"
	LUA_LDIR	= LUA_ROOT.."share/lua/5.1/"
	LUA_CDIR	= LUA_ROOT.."lib/lua/5.1/"
	if LUA_XROOT then
		LUA_JDIR	= LUA_XROOT.."share/luajit-2.0.0-beta9/"
		LUA_XPATH = ";"..LUA_XROOT.."share/lua/5.1/?.lua;"..LUA_XROOT.."share/lua/5.1/?/init.lua"
		LUA_XCPATH	= LUA_XROOT.."lib/lua/5.1/?.so;"
	else
		LUA_JDIR	= LUA_ROOT.."share/luajit-2.0.0-beta9/"
		LUA_XPATH	= ""
		LUA_XCPATH	= ""
	end
	LUA_PATH_DEFAULT 	= "./?.lua;"..LUA_JDIR.."?.lua;"..LUA_LDIR.."?.lua;"..LUA_LDIR.."?/init.lua"..LUA_XPATH
	LUA_CPATH_DEFAULT	= "./?.so;"..LUA_CDIR.."?.so;"..LUA_XCPATH..LUA_CDIR.."loadall.so"
end



-- Environment variable names for path overrides and initialization code.
LUA_PATH	= "LUA_PATH"
LUA_CPATH	= "LUA_CPATH"
LUA_INIT	= "LUA_INIT"

-- Special file system characters.
if ffi.abi("win") then
	LUA_DIRSEP	= "\\"
else
	LUA_DIRSEP	= "/"
end

LUA_PATHSEP = ";"
LUA_PATH_MARK = "?"
LUA_EXECDIR	= "!"
LUA_IGMARK	= "-"
LUA_PATH_CONFIG = LUA_DIRSEP.."\n"..LUA_PATHSEP.."\n"..LUA_PATH_MARK.."\n"..LUA_EXECDIR.."\n"..LUA_IGMARK

-- Quoting in error messages.
function LUA_QL(x)
	return "'"..x.."'"
end

LUA_QS = LUA_QL("%s")


-- Various tunables.
LUAI_MAXSTACK	=65500	-- Max. # of stack slots for a thread (<64K).
LUAI_MAXCSTACK	=8000	-- Max. # of stack slots for a C func (<10K).
LUAI_GCPAUSE	=200	-- Pause GC until memory is at 200%.
LUAI_GCMUL	=200	-- Run GC at 200% of allocation speed.
LUA_MAXCAPTURES	=32	-- Max. pattern captures.


-- Compatibility with older library function names.
LUA_COMPAT_MOD	= nil	-- OLD: math.mod, NEW: math.fmod
LUA_COMPAT_GFIND = nil	-- OLD: string.gfind, NEW: string.gmatch


-- Configuration for the frontend (the luajit executable).
if (luajit_c) then
	LUA_PROGNAME	= "luajit"  -- Fallback frontend name.
	LUA_PROMPT	= "> "	-- Interactive prompt.
	LUA_PROMPT2	= ">> "	-- Continuation prompt.
	LUA_MAXINPUT	= 512	-- Max. input line length.
end

ffi.cdef[[
/* Note: changing the following defines breaks the Lua 5.1 ABI. */
typedef ptrdiff_t LUA_INTEGER;
]]


ffi.cdef[[
/* The following defines are here only for compatibility with luaconf.h
** from the standard Lua distribution. They must not be changed for LuaJIT.
*/
//#define LUA_NUMBER_DOUBLE
typedef double  LUA_NUMBER;
typedef double	LUAI_UACNUMBER;
typedef long	LUA_INTFRM_T;
]]

LUA_NUMBER_SCAN		= "%lf"
LUA_NUMBER_FMT		= "%.14g"
LUAI_MAXNUMBER2STR	= 32
LUA_INTFRMLEN		=	"l"


function lua_number2str(n)
	return string.format(LUA_NUMBER_FMT, n)
end

function lua_str2number(s)
	return tonumber(s)
end





--[===========================================[
	FROM: lua.h
--]===========================================]
LUA_VERSION		="Lua 5.1"
LUA_RELEASE		="Lua 5.1.4"
LUA_VERSION_NUM	=501
LUA_COPYRIGHT	="Copyright (C) 1994-2008 Lua.org, PUC-Rio"
LUA_AUTHORS		="R. Ierusalimschy, L. H. de Figueiredo & W. Celes"

-- mark for precompiled code (`<esc>Lua')
LUA_SIGNATURE	= "\033Lua"

-- option for multiple returns in `lua_pcall' and `lua_call'
LUA_MULTRET		= (-1)


--
-- pseudo-indices
--
LUA_REGISTRYINDEX	= (-10000)
LUA_ENVIRONINDEX	= (-10001)
LUA_GLOBALSINDEX	= (-10002)

function lua_upvalueindex(i)
	return (LUA_GLOBALSINDEX-(i))
end

-- thread status; 0 is OK
LUA_YIELD		= 1
LUA_ERRRUN		= 2
LUA_ERRSYNTAX	= 3
LUA_ERRMEM		= 4
LUA_ERRERR		= 5


--[[
	*** WARNING ***

	The definition of BUFSIZ is very system independent
	it is defined in the C header file "stdio.h", and it
	might differ from system to system.
--]]
ffi.cdef[[
enum {
	BUFSIZ = 512
};

typedef struct lua_State lua_State;
]]

ffi.cdef[[

typedef int (*lua_CFunction) (lua_State *L);


/*
** functions that read/write blocks when loading/dumping Lua chunks
*/
typedef const char * (*lua_Reader) (lua_State *L, void *ud, size_t *sz);

typedef int (*lua_Writer) (lua_State *L, const void* p, size_t sz, void* ud);


/*
** prototype for memory-allocation functions
*/
typedef void * (*lua_Alloc) (void *ud, void *ptr, size_t osize, size_t nsize);

]]


--
-- basic types
--
LUA_TNONE		= (-1)

LUA_TNIL		= 0
LUA_TBOOLEAN		= 1
LUA_TLIGHTUSERDATA	= 2
LUA_TNUMBER		= 3
LUA_TSTRING		= 4
LUA_TTABLE		= 5
LUA_TFUNCTION		= 6
LUA_TUSERDATA		= 7
LUA_TTHREAD		= 8


-- minimum Lua stack available to a C function
LUA_MINSTACK	= 20


ffi.cdef[[
/* type of numbers in Lua */
typedef LUA_NUMBER lua_Number;


/* type for integer functions */
typedef LUA_INTEGER lua_Integer;

]]


ffi.cdef[[
/*
** state manipulation
*/
lua_State *(lua_newstate) (lua_Alloc f, void *ud);
void       (lua_close) (lua_State *L);
lua_State *(lua_newthread) (lua_State *L);

lua_CFunction (lua_atpanic) (lua_State *L, lua_CFunction panicf);
]]

ffi.cdef[[
/*
** basic stack manipulation
*/
int   (lua_gettop) (lua_State *L);
void  (lua_settop) (lua_State *L, int idx);
void  (lua_pushvalue) (lua_State *L, int idx);
void  (lua_remove) (lua_State *L, int idx);
void  (lua_insert) (lua_State *L, int idx);
void  (lua_replace) (lua_State *L, int idx);
int   (lua_checkstack) (lua_State *L, int sz);

void  (lua_xmove) (lua_State *from, lua_State *to, int n);
]]


ffi.cdef[[
/*
** access functions (stack -> C)
*/

int             (lua_isnumber) (lua_State *L, int idx);
int             (lua_isstring) (lua_State *L, int idx);
int             (lua_iscfunction) (lua_State *L, int idx);
int             (lua_isuserdata) (lua_State *L, int idx);
int             (lua_type) (lua_State *L, int idx);
const char     *(lua_typename) (lua_State *L, int tp);

int            (lua_equal) (lua_State *L, int idx1, int idx2);
int            (lua_rawequal) (lua_State *L, int idx1, int idx2);
int            (lua_lessthan) (lua_State *L, int idx1, int idx2);

lua_Number      (lua_tonumber) (lua_State *L, int idx);
lua_Integer     (lua_tointeger) (lua_State *L, int idx);
int             (lua_toboolean) (lua_State *L, int idx);
const char     *(lua_tolstring) (lua_State *L, int idx, size_t *len);
size_t          (lua_objlen) (lua_State *L, int idx);
lua_CFunction   (lua_tocfunction) (lua_State *L, int idx);
void	       *(lua_touserdata) (lua_State *L, int idx);
lua_State      *(lua_tothread) (lua_State *L, int idx);
const void     *(lua_topointer) (lua_State *L, int idx);
]]


ffi.cdef[[
/*
** push functions (C -> stack)
*/
void  (lua_pushnil) (lua_State *L);
void  (lua_pushnumber) (lua_State *L, lua_Number n);
void  (lua_pushinteger) (lua_State *L, lua_Integer n);
void  (lua_pushlstring) (lua_State *L, const char *s, size_t l);
void  (lua_pushstring) (lua_State *L, const char *s);
const char *(lua_pushvfstring) (lua_State *L, const char *fmt,
                                                      va_list argp);
const char *(lua_pushfstring) (lua_State *L, const char *fmt, ...);
void  (lua_pushcclosure) (lua_State *L, lua_CFunction fn, int n);
void  (lua_pushboolean) (lua_State *L, int b);
void  (lua_pushlightuserdata) (lua_State *L, void *p);
int   (lua_pushthread) (lua_State *L);
]]

ffi.cdef[[
/*
** get functions (Lua -> stack)
*/
void  (lua_gettable) (lua_State *L, int idx);
void  (lua_getfield) (lua_State *L, int idx, const char *k);
void  (lua_rawget) (lua_State *L, int idx);
void  (lua_rawgeti) (lua_State *L, int idx, int n);
void  (lua_createtable) (lua_State *L, int narr, int nrec);
void *(lua_newuserdata) (lua_State *L, size_t sz);
int   (lua_getmetatable) (lua_State *L, int objindex);
void  (lua_getfenv) (lua_State *L, int idx);
]]

ffi.cdef[[
/*
** set functions (stack -> Lua)
*/
void  (lua_settable) (lua_State *L, int idx);
void  (lua_setfield) (lua_State *L, int idx, const char *k);
void  (lua_rawset) (lua_State *L, int idx);
void  (lua_rawseti) (lua_State *L, int idx, int n);
int   (lua_setmetatable) (lua_State *L, int objindex);
int   (lua_setfenv) (lua_State *L, int idx);
]]


ffi.cdef[[
/*
** `load' and `call' functions (load and run Lua code)
*/
void  (lua_call) (lua_State *L, int nargs, int nresults);
int   (lua_pcall) (lua_State *L, int nargs, int nresults, int errfunc);
int   (lua_cpcall) (lua_State *L, lua_CFunction func, void *ud);
int   (lua_load) (lua_State *L, lua_Reader reader, void *dt,
                                        const char *chunkname);

int (lua_dump) (lua_State *L, lua_Writer writer, void *data);
]]


ffi.cdef[[
/*
** coroutine functions
*/
int  (lua_yield) (lua_State *L, int nresults);
int  (lua_resume) (lua_State *L, int narg);
int  (lua_status) (lua_State *L);
]]


--
-- garbage-collection function and options
--

LUA_GCSTOP		= 0
LUA_GCRESTART	= 1
LUA_GCCOLLECT	= 2
LUA_GCCOUNT		= 3
LUA_GCCOUNTB	= 4
LUA_GCSTEP		= 5
LUA_GCSETPAUSE	= 6
LUA_GCSETSTEPMUL= 7

ffi.cdef[[
int (lua_gc) (lua_State *L, int what, int data);
]]

ffi.cdef[[
/*
** miscellaneous functions
*/

int   (lua_error) (lua_State *L);

int   (lua_next) (lua_State *L, int idx);

void  (lua_concat) (lua_State *L, int n);

lua_Alloc (lua_getallocf) (lua_State *L, void **ud);
void lua_setallocf (lua_State *L, lua_Alloc f, void *ud);
]]


--[[
   ===============================================================
   some useful macros
   ===============================================================
--]]

function lua_pop(L,n) return luajit.lua_settop(L, -(n)-1) end

function lua_newtable(L) return luajit.lua_createtable(L, 0, 0) end

function lua_register(L,n,f)
	return luajit.lua_pushcfunction(L, (f)), luajit.lua_setglobal(L, (n))
end

function lua_pushcfunction(L,f)	return luajit.lua_pushcclosure(L, (f), 0) end

function lua_strlen(L,i)		return luajit.lua_objlen(L, (i)) end

function lua_isfunction(L,n)	return (luajit.lua_type(L, (n)) == LUA_TFUNCTION) end
function lua_istable(L,n)	return (luajit.lua_type(L, (n)) == LUA_TTABLE) end
function lua_islightuserdata(L,n)	return (luajit.lua_type(L, (n)) == LUA_TLIGHTUSERDATA) end
function lua_isnil(L,n)		return (luajit.lua_type(L, (n)) == LUA_TNIL) end
function lua_isboolean(L,n)	return (luajit.lua_type(L, (n)) == LUA_TBOOLEAN) end
function lua_isthread(L,n)	return (luajit.lua_type(L, (n)) == LUA_TTHREAD) end
function lua_isnone(L,n)		return (luajit.lua_type(L, (n)) == LUA_TNONE) end
function lua_isnoneornil(L, n)	return (luajit.lua_type(L, (n)) <= 0) end

function lua_pushliteral(L, s)	return luajit.lua_pushlstring(L, ""..s, (string.len(s)/ffi.sizeof("char"))-1) end

function lua_setglobal(L,s)	return luajit.lua_setfield(L, LUA_GLOBALSINDEX, (s)) end
function lua_getglobal(L,s)	return luajit.lua_getfield(L, LUA_GLOBALSINDEX, (s)) end

function lua_tostring(L,i)	return luajit.lua_tolstring(L, (i), nil) end


--
-- compatibility macros and functions
--

function lua_open() return luajit.luaL_newstate() end

function lua_getregistry(L) return luajit.lua_pushvalue(L, LUA_REGISTRYINDEX) end

function lua_getgccount(L)	return luajit.lua_gc(L, LUA_GCCOUNT, 0) end

--lua_Chunkreader	= luajit.lua_Reader
--lua_Chunkwriter	= luajit.lua_Writer

ffi.cdef[[
/* hack */
void lua_setlevel	(lua_State *from, lua_State *to);
]]



--[[
   ======================================================================
   Debug API
   =======================================================================
--]]


--
-- Event codes
--
LUA_HOOKCALL	= 0
LUA_HOOKRET		= 1
LUA_HOOKLINE	= 2
LUA_HOOKCOUNT	= 3
LUA_HOOKTAILRET = 4


--
-- Event masks
--
LUA_MASKCALL	= lshift(1, LUA_HOOKCALL)
LUA_MASKRET		= lshift(1, LUA_HOOKRET)
LUA_MASKLINE	= lshift(1, LUA_HOOKLINE)
LUA_MASKCOUNT	= lshift(1, LUA_HOOKCOUNT)

cdef[[
typedef struct lua_Debug lua_Debug;  /* activation record */


/* Functions to be called by the debuger in specific events */
typedef void (*lua_Hook) (lua_State *L, lua_Debug *ar);


int lua_getstack (lua_State *L, int level, lua_Debug *ar);
int lua_getinfo (lua_State *L, const char *what, lua_Debug *ar);
const char *lua_getlocal (lua_State *L, const lua_Debug *ar, int n);
const char *lua_setlocal (lua_State *L, const lua_Debug *ar, int n);
const char *lua_getupvalue (lua_State *L, int funcindex, int n);
const char *lua_setupvalue (lua_State *L, int funcindex, int n);

int lua_sethook (lua_State *L, lua_Hook func, int mask, int count);
lua_Hook lua_gethook (lua_State *L);
int lua_gethookmask (lua_State *L);
int lua_gethookcount (lua_State *L);
]]

ffi.cdef[[

enum {
	LUA_IDSIZE	= 60,	/* Size of lua_Debug.short_src. */

	LUAL_BUFFERSIZE = BUFSIZ	/* Size of lauxlib and io.* buffers. */
};


struct lua_Debug {
  int event;
  const char *name;	/* (n) */
  const char *namewhat;	/* (n) `global', `local', `field', `method' */
  const char *what;	/* (S) `Lua', `C', `main', `tail' */
  const char *source;	/* (S) */
  int currentline;	/* (l) */
  int nups;		/* (u) number of upvalues */
  int linedefined;	/* (S) */
  int lastlinedefined;	/* (S) */
  char short_src[LUA_IDSIZE]; /* (S) */
  /* private part */
  int i_ci;  /* active function */
};
]]





--[===========================================[
	FROM: lauxlib.h
--]===========================================]


function luaL_getn(L,i)
	return luajit.lua_objlen(L, i)
end

function luaL_setn(L,i,j)
	return 0 -- no op!
end


-- extra error code for `luaL_load'
LUA_ERRFILE = LUA_ERRERR+1

cdef[[
typedef struct luaL_Reg {
  const char *name;
  lua_CFunction func;
} luaL_Reg;

void (luaL_openlib) (lua_State *L, const char *libname,
                                const luaL_Reg *l, int nup);
void (luaL_register) (lua_State *L, const char *libname,
                                const luaL_Reg *l);
int (luaL_getmetafield) (lua_State *L, int obj, const char *e);
int (luaL_callmeta) (lua_State *L, int obj, const char *e);
int (luaL_typerror) (lua_State *L, int narg, const char *tname);
int (luaL_argerror) (lua_State *L, int numarg, const char *extramsg);
const char *(luaL_checklstring) (lua_State *L, int numArg,
                                                          size_t *l);
const char *(luaL_optlstring) (lua_State *L, int numArg,
                                          const char *def, size_t *l);
lua_Number (luaL_checknumber) (lua_State *L, int numArg);
lua_Number (luaL_optnumber) (lua_State *L, int nArg, lua_Number def);

lua_Integer (luaL_checkinteger) (lua_State *L, int numArg);
lua_Integer (luaL_optinteger) (lua_State *L, int nArg,
                                          lua_Integer def);

void (luaL_checkstack) (lua_State *L, int sz, const char *msg);
void (luaL_checktype) (lua_State *L, int narg, int t);
void (luaL_checkany) (lua_State *L, int narg);

int   (luaL_newmetatable) (lua_State *L, const char *tname);
void *(luaL_checkudata) (lua_State *L, int ud, const char *tname);

void (luaL_where) (lua_State *L, int lvl);
int (luaL_error) (lua_State *L, const char *fmt, ...);

int (luaL_checkoption) (lua_State *L, int narg, const char *def,
                                   const char *const lst[]);

int (luaL_ref) (lua_State *L, int t);
void (luaL_unref) (lua_State *L, int t, int ref);

int (luaL_loadfile) (lua_State *L, const char *filename);
int (luaL_loadbuffer) (lua_State *L, const char *buff, size_t sz,
                                  const char *name);
int (luaL_loadstring) (lua_State *L, const char *s);

lua_State *(luaL_newstate) (void);


const char *(luaL_gsub) (lua_State *L, const char *s, const char *p,
                                                  const char *r);

const char *(luaL_findtable) (lua_State *L, int idx,
                                         const char *fname, int szhint);
]]



--[[
** ===============================================================
** some useful macros
** ===============================================================
--]]

function luaL_argcheck(L, cond,numarg,extramsg)
	return cond or luajit.luaL_argerror(L, numarg, extramsg)
end

function luaL_checkstring(L,n)
	return (luajit.luaL_checklstring(L, (n), nil))
end

function luaL_optstring(L,n,d)	return (luajit.luaL_optlstring(L, (n), (d), nil)) end
function luaL_checkint(L,n)	return (luajit.luaL_checkinteger(L, (n))) end
function luaL_optint(L,n,d)	return (luajit.luaL_optinteger(L, (n), (d))) end
function luaL_checklong(L,n)	return (luajit.luaL_checkinteger(L, (n))) end
function luaL_optlong(L,n,d)	return (luajit.luaL_optinteger(L, (n), (d))) end

function luaL_typename(L,i)	return luajit.lua_typename(L, luajit.lua_type(L,(i))) end

function luaL_dofile(L, fn)
	return (luaL_loadfile(L, fn) or luajit.lua_pcall(L, 0, LUA_MULTRET, 0))
end

function luaL_dostring(L, s)
	local result = luajit.luaL_loadstring(L, s)

	if result == 0 then
		result = luajit.lua_pcall(L, 0, LUA_MULTRET, 0)
	end

	return result
end

function luaL_getmetatable(L,n)	return (luajit.lua_getfield(L, LUA_REGISTRYINDEX, (n))) end

function luaL_opt(L,f,n,d)
	if luajit.lua_isnoneornil(L,n) then
		return d
	end

	return  f(L,n)
end

--[[
** {======================================================
** Generic Buffer manipulation
** =======================================================
--]]


cdef[[
typedef struct luaL_Buffer {
  char *p;			/* current position in buffer */
  int lvl;  /* number of strings in the stack (level) */
  lua_State *L;
  char buffer[LUAL_BUFFERSIZE];
} luaL_Buffer;
]]
--[[
function luaL_addchar(B,c)
  (B.p < (B.buffer+LUAL_BUFFERSIZE) or luajit.luaL_prepbuffer(B)), (*(B).p++ = c)
end
--]]
-- compatibility only
--luaL_putchar = luaL_addchar

function luaL_addsize(B,n)
	B.p = B.p + n
end

cdef[[
void (luaL_buffinit) (lua_State *L, luaL_Buffer *B);
char *(luaL_prepbuffer) (luaL_Buffer *B);
void (luaL_addlstring) (luaL_Buffer *B, const char *s, size_t l);
void (luaL_addstring) (luaL_Buffer *B, const char *s);
void (luaL_addvalue) (luaL_Buffer *B);
void (luaL_pushresult) (luaL_Buffer *B);
]]

-- ======================================================


-- compatibility with ref system

-- pre-defined references
LUA_NOREF       = (-2)
LUA_REFNIL      = (-1)

function lua_ref(L,lock)
	if lock then
		luaL_ref(L, LUA_REGISTRYINDEX)
	else
		luajit.lua_pushstring(L, "unlocked references are obsolete")
		luajit.lua_error(L)
	end
end

function lua_unref(L,ref)
	return luaL_unref(L, LUA_REGISTRYINDEX, (ref))
end

function lua_getref(L,ref)
	return lua_rawgeti(L, LUA_REGISTRYINDEX, (ref))
end


luaL_reg = luaL_Reg



--[===========================================[
	FROM: lualib.h
--]===========================================]


 LUA_FILEHANDLE	= "FILE*"

 LUA_COLIBNAME	= "coroutine"
 LUA_MATHLIBNAME	= "math"
 LUA_STRLIBNAME	= "string"
 LUA_TABLIBNAME	= "table"
 LUA_IOLIBNAME	= "io"
 LUA_OSLIBNAME	= "os"
 LUA_LOADLIBNAME	= "package"
 LUA_DBLIBNAME	= "debug"
 LUA_BITLIBNAME	= "bit"
 LUA_JITLIBNAME	= "jit"
 LUA_FFILIBNAME	= "ffi"

cdef[[
int luaopen_base(lua_State *L);
int luaopen_math(lua_State *L);
int luaopen_string(lua_State *L);
int luaopen_table(lua_State *L);
int luaopen_io(lua_State *L);
int luaopen_os(lua_State *L);
int luaopen_package(lua_State *L);
int luaopen_debug(lua_State *L);
int luaopen_bit(lua_State *L);
int luaopen_jit(lua_State *L);
int luaopen_ffi(lua_State *L);

void luaL_openlibs(lua_State *L);
]]




return luajit

--[[


	This software was adapted from the original luaconf.h, lua.h, and luajit.h files
	Those original files contained the following copyrights.

	The Lua form of these C header files were created by:

	Author: William Adams (william_a_adams@msn.com)

	Although the Lua versions of the files have some changes to match the luajit
	ffi style, there were no substantive changes beyond that.

/* }====================================================================== */


/******************************************************************************
* Copyright (C) 1994-2008 Lua.org, PUC-Rio.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining
* a copy of this software and associated documentation files (the
* "Software"), to deal in the Software without restriction, including
* without limitation the rights to use, copy, modify, merge, publish,
* distribute, sublicense, and/or sell copies of the Software, and to
* permit persons to whom the Software is furnished to do so, subject to
* the following conditions:
*
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
******************************************************************************/
--]]
