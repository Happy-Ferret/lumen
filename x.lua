current_target="js";current_language="lua";function length(x)return(#x); end function sub(x,from,upto)if is_string(x) then return(string.sub(x,(from+1),upto)); else do upto=(upto or length(x));local i=from;local j=0;local x2={};while (i<upto) do x2[(j+1)]=x[(i+1)];i=(i+1);j=(j+1); end return(x2); end  end  end function push(arr,x)arr[(length(arr)+1)]=x; end function join(a1,a2)do local a3={};local i=0;local len=length(a1);while (i<len) do a3[(i+1)]=a1[(i+1)];i=(i+1); end while (i<(len+length(a2))) do a3[(i+1)]=a2[((i-len)+1)];i=(i+1); end return(a3); end  end function char(str,n)return(sub(str,n,(n+1))); end function find(str,pattern,start)do if start then start=(start+1); end local i=string.find(str,pattern,start,true);return((i and (i-1))); end  end function read_file(path)do local f=io.open(path);return(f:read("*a")); end  end function write_file(path,data)do local f=io.open(path,"w");return(f:write(data)); end  end function exit(code)return(os.exit(code)); end function is_string(x)return((type(x)=="string")); end function is_number(x)return((type(x)=="number")); end function is_boolean(x)return((type(x)=="boolean")); end function is_composite(x)return((type(x)=="table")); end function is_atom(x)return((not is_composite(x))); end function is_table(x)return((is_composite(x) and (x[1]==nil))); end function is_list(x)return((is_composite(x) and (not (x[1]==nil)))); end function parse_number(str)return(tonumber(str)); end function to_string(x)if (x==nil) then return("nil"); elseif is_boolean(x) then return(((x and "true") or "false")); elseif is_atom(x) then return((x.."")); else local str="(";do local i=0;local _5=x;while (i<length(_5)) do local y=_5[(i+1)];str=(str..to_string(y));if (i<(length(x)-1)) then str=(str.." "); end i=(i+1); end  end return((str..")")); end  end function apply(f,args)return(f(unpack(args))); end unique_counter=0;function make_unique(prefix)unique_counter=(unique_counter+1);return(("_"..(prefix or "")..unique_counter)); end eval_result=nil;function eval(x)local y=("eval_result="..x);local f=load(y);if f then f();return(eval_result); else local f=load(x);return((f and f())); end  end eof={};delimiters={};delimiters["("]=true;delimiters[")"]=true;delimiters[";"]=true;delimiters[eof]=true;delimiters["\n"]=true;whitespace={};whitespace[" "]=true;whitespace["\t"]=true;whitespace["\n"]=true;function make_stream(str)return({pos=0,string=str,len=length(str)}); end function peek_char(s)return((((s.pos<s.len) and char(s.string,s.pos)) or eof)); end function read_char(s)local c=peek_char(s);if c then s.pos=(s.pos+1);return(c); end  end function skip_non_code(s)while true do local c=peek_char(s);if (not c) then break; elseif whitespace[c] then read_char(s); elseif (c==";") then while (c and (not (c=="\n"))) do c=read_char(s); end skip_non_code(s); else break; end  end  end function read_atom(s)local str="";while true do local c=peek_char(s);if (c and ((not whitespace[c]) and (not delimiters[c]))) then str=(str..c);read_char(s); else break; end  end local n=parse_number(str);return((((n==nil) and str) or n)); end function read_list(s)read_char(s);local l={};while true do skip_non_code(s);local c=peek_char(s);if (c and (not (c==")"))) then push(l,read(s)); elseif c then read_char(s);break; else error(("Expected ) at "..s.pos)); end  end return(l); end function read_string(s)read_char(s);local str="\"";while true do local c=peek_char(s);if (c and (not (c=="\""))) then if (c=="\\") then str=(str..read_char(s)); end str=(str..read_char(s)); elseif c then read_char(s);break; else error(("Expected \" at "..s.pos)); end  end return((str.."\"")); end function read_quote(s)read_char(s);return({"quote",read(s)}); end function read_unquote(s)read_char(s);if (peek_char(s)=="@") then read_char(s);return({"unquote-splicing",read(s)}); else return({"unquote",read(s)}); end  end function read(s)skip_non_code(s);local c=peek_char(s);if (c==eof) then return(c); elseif (c=="(") then return(read_list(s)); elseif (c==")") then return(error(("Unexpected ) at "..s.pos))); elseif (c=="\"") then return(read_string(s)); elseif (c=="'") then return(read_quote(s)); elseif (c==",") then return(read_unquote(s)); else return(read_atom(s)); end  end function read_from_string(str)return(read(make_stream(str))); end operators={};operators["common"]={};operators["common"]["+"]="+";operators["common"]["-"]="-";operators["common"]["*"]="*";operators["common"]["/"]="/";operators["common"]["<"]="<";operators["common"][">"]=">";operators["common"]["="]="==";operators["common"]["<="]="<=";operators["common"][">="]=">=";operators["js"]={};operators["js"]["and"]="&&";operators["js"]["or"]="||";operators["js"]["cat"]="+";operators["lua"]={};operators["lua"]["and"]=" and ";operators["lua"]["or"]=" or ";operators["lua"]["cat"]="..";function get_op(op)return((operators["common"][op] or operators[current_target][op])); end macros={};special={};function is_call(form)return(is_string(form[1])); end function is_operator(form)return((not (get_op(form[1])==nil))); end function is_special(form)return((not (special[form[1]]==nil))); end function is_macro_call(form)return((not (macros[form[1]]==nil))); end function is_macro_definition(form)return((form[1]=="macro")); end function compile_args(forms,is_compile)local str="(";do local i=0;local _6=forms;while (i<length(_6)) do local x=_6[(i+1)];local x1=((is_compile and compile(x)) or normalize(x));str=(str..x1);if (i<(length(forms)-1)) then str=(str..","); end i=(i+1); end  end return((str..")")); end function compile_body(forms,is_tail)local str=(((current_target=="js") and "{") or "");do local i=0;local _7=forms;while (i<length(_7)) do local x=_7[(i+1)];local is_t=(is_tail and (i==(length(forms)-1)));str=(str..compile(x,true,is_t));i=(i+1); end  end return((((current_target=="js") and (str.."}")) or str)); end function normalize(id)local id2="";local i=0;while (i<length(id)) do local c=char(id,i);if (c=="-") then c="_"; end id2=(id2..c);i=(i+1); end local last=(length(id)-1);if (char(id,last)=="?") then local name=sub(id2,0,last);id2=("is_"..name); end return(id2); end function compile_atom(form)if (form=="nil") then return((((current_target=="js") and "undefined") or "nil")); elseif (is_string(form) and (not (char(form,0)=="\""))) then return(normalize(form)); else return(to_string(form)); end  end function compile_call(form)local fn=compile(form[1]);local args=compile_args(sub(form,1),true);return((fn..args)); end function compile_operator(form)local str="(";local op=get_op(form[1]);do local i=1;local _8=form;while (i<length(_8)) do local arg=_8[(i+1)];str=(str..compile(arg));if (i<(length(form)-1)) then str=(str..op); end i=(i+1); end  end return((str..")")); end function compile_do(forms,is_tail)local body=compile_body(forms,is_tail);return((((current_target=="js") and body) or ("do "..body.." end "))); end function compile_set(form)if (length(form)<2) then error("Missing right-hand side in assignment"); end local lh=compile(form[1]);local rh=compile(form[2]);return((lh.."="..rh)); end function compile_branch(branch,is_first,is_last,is_tail)local condition=compile(branch[1]);local body=compile_body(sub(branch,1),is_tail);local tr="";if (is_last and (current_target=="lua")) then tr=" end "; end if is_first then return((((current_target=="js") and ("if("..condition..")"..body)) or ("if "..condition.." then "..body..tr))); elseif (is_last and (condition=="true")) then return((((current_target=="js") and ("else"..body)) or (" else "..body.." end "))); else return((((current_target=="js") and ("else if("..condition..")"..body)) or (" elseif "..condition.." then "..body..tr))); end  end function compile_if(form,is_tail)local str="";do local i=0;local _9=form;while (i<length(_9)) do local branch=_9[(i+1)];local is_last=(i==(length(form)-1));local is_first=(i==0);str=(str..compile_branch(branch,is_first,is_last,is_tail));i=(i+1); end  end return(str); end function expand_function(args,body)do local i=0;local _10=args;while (i<length(_10)) do local arg=_10[(i+1)];if (arg=="...") then args=sub(args,0,i);local name=make_unique();local expr={"list","..."};if (current_target=="js") then expr={"Array.prototype.slice.call","arguments",i}; else push(args,"..."); end process_body(body,name);body=join({{"local",name,expr}},body);break; end i=(i+1); end  end return({args,body}); end function process_body(body,vararg)do local i=0;local _11=body;while (i<length(_11)) do local form=_11[(i+1)];if (form=="...") then body[(i+1)]=vararg; elseif is_list(form) then process_body(form,vararg); end i=(i+1); end  end  end function compile_function(form)local i=0;local name="";if is_string(form[1]) then i=1;name=normalize(form[1]); end local expanded=expand_function(form[(i+1)],sub(form,(i+1)));local args=compile_args(expanded[1]);local body=compile_body(expanded[2],true);local tr=(((current_target=="lua") and " end ") or "");return(("function "..name..args..body..tr)); end function compile_get(form)local object=compile(form[1]);local key=compile(form[2]);if ((current_target=="lua") and (char(object,0)=="{")) then object=("("..object..")"); end return((object.."["..key.."]")); end function compile_dot(form)local object=compile(form[1]);local key=form[2];return((object.."."..key)); end function compile_not(form)local expr=compile(form[1]);local open=(((current_target=="js") and "!(") or "(not ");return((open..expr..")")); end function compile_local(form)local lh=compile(form[1]);local keyword=(((current_target=="js") and "var ") or "local ");if (form[2]==nil) then return((keyword..lh)); else local rh=compile(form[2]);return((keyword..lh.."="..rh)); end  end function compile_while(form)local condition=compile(form[1]);local body=compile_body(sub(form,1));return((((current_target=="js") and ("while("..condition..")"..body)) or ("while "..condition.." do "..body.." end "))); end function compile_list(forms,is_quoted)local open=(((current_target=="lua") and "{") or "[");local close=(((current_target=="lua") and "}") or "]");local str="";do local i=0;local _12=forms;while (i<length(_12)) do local x=_12[(i+1)];if (is_list(x) and (x[1]=="unquote-splicing")) then local x1=compile(x[2]);local x2=compile_list(sub(forms,(i+1)),true);open=("join("..open);close=(close..",join("..x1..","..x2.."))");break; else local x1=((is_quoted and quote_form(x)) or compile(x));str=(str..x1);if (i<(length(forms)-1)) then str=(str..","); end  end i=(i+1); end  end return((open..str..close)); end function compile_table(forms)local sep=(((current_target=="lua") and "=") or ":");local str="{";local i=0;while (i<(length(forms)-1)) do local k=compile(forms[(i+1)]);local v=compile(forms[((i+1)+1)]);str=(str..k..sep..v);if (i<(length(forms)-2)) then str=(str..","); end i=(i+2); end return((str.."}")); end function compile_each(forms)local args=forms[1];local t=args[1];local k=args[2];local v=args[3];local body=sub(forms,1);if (current_target=="lua") then local body1=compile_body(body);local t1=compile(t);return(("for "..k..","..v.." in pairs("..t1..") do "..body1.." end")); else local body1=compile_body(join({{"set",v,{"get",t,k}},},join(body,{})));return(("for("..k.." in "..t..")"..body1)); end  end function compile_to_string(form)if (is_string(form) and (char(form,0)=="\"")) then local str=sub(form,1,(length(form)-1));return(("\"\\\""..str.."\\\"\"")); elseif is_string(form) then return(("\""..form.."\"")); else return(to_string(form)); end  end function quote_form(form)if is_atom(form) then return(compile_to_string(form)); elseif (form[1]=="unquote") then return(compile(form[2])); else return(compile_list(form,true)); end  end function compile_quote(forms)return(quote_form(forms[1])); end function compile_macro(form)local tmp=current_target;current_target=current_language;eval(compile_function(form,true));local name=form[1];local register={"set",{"get","macros",compile_to_string(name)},name};eval(compile(register,true));current_target=tmp;return(""); end function compile_special(form,is_stmt,is_tail)local name=form[1];local sp=special[name];local is_tr=(is_stmt and (not sp["terminated"]));local tr=((is_tr and ";") or "");local fn=sp["compiler"];return((fn(sub(form,1),is_tail)..tr)); end special["do"]={compiler=compile_do,terminated=true,statement=true};special["if"]={compiler=compile_if,terminated=true,statement=true};special["function"]={compiler=compile_function,terminated=true,statement=true};special["while"]={compiler=compile_while,terminated=true,statement=true};special["macro"]={compiler=compile_macro,statement=true,terminated=true};special["local"]={compiler=compile_local,statement=true};special["set"]={compiler=compile_set,statement=true};special["each"]={compiler=compile_each,statement=true};special["get"]={compiler=compile_get};special["dot"]={compiler=compile_dot};special["not"]={compiler=compile_not};special["list"]={compiler=compile_list};special["table"]={compiler=compile_table};special["quote"]={compiler=compile_quote};function is_can_return(form)if is_macro_call(form) then return(false); elseif is_special(form) then return((not special[form[1]]["statement"])); else return(true); end  end function compile(form,is_stmt,is_tail)local tr=((is_stmt and ";") or "");if (is_tail and is_can_return(form)) then form={"return",form}; end if (form==nil) then return(""); elseif is_atom(form) then return((compile_atom(form)..tr)); elseif is_call(form) then if is_operator(form) then return((compile_operator(form)..tr)); elseif is_special(form) then return(compile_special(form,is_stmt,is_tail)); elseif is_macro_call(form) then local fn=macros[form[1]];local form=apply(fn,sub(form,1));return(compile(form,is_stmt,is_tail)); else return((compile_call(form)..tr)); end  else return(error(("Unexpected form: "..to_string(form)))); end  end function compile_file(filename)local form;local output="";local s=make_stream(read_file(filename));while true do form=read(s);if (form==eof) then break; end output=(output..compile(form,true)); end return(output); end passed=0;function assert_equal(a,b)local sa=to_string(a);local sb=to_string(b);if (not (sa==sb)) then return(error((" failed: expected "..sa.." was "..sb))); else passed=(passed+1); end  end function run_tests()print(" running tests...");assert_equal(18,18);assert_equal(123,123);assert_equal(0.123,0.123);assert_equal(17,(16+1));assert_equal(4,(7-3));assert_equal(5,(10/2));assert_equal(6,(2*3));assert_equal(true,(not false));assert_equal(true,(true or false));assert_equal(false,(true and false));assert_equal(17,((true and 17) or 18));assert_equal(18,((false and 17) or 18));assert_equal("foo","foo");assert_equal("\"bar\"","\"bar\"");assert_equal(1,length("\""));assert_equal(2,length("a\""));assert_equal("foobar",("foo".."bar"));assert_equal(2,length(("\"".."\"")));assert_equal("a","a");assert_equal("a","a");assert_equal("a",char("bar",1));assert_equal("uu",sub("quux",1,3));assert_equal({},{});assert_equal({1},{1});assert_equal({"a"},{"a"});assert_equal({"a"},{"a"});assert_equal(false,({"a"}=={"\"a\""}));assert_equal(5,length({1,2,3,4,5}));assert_equal(3,length({1,{2,3,4},5}));assert_equal(3,length(({1,{2,3,4},5})[2]));local a="bar";assert_equal({1,2,"bar"},{1,2,a});assert_equal(false,("\"a\""=="a"));assert_equal(false,({"a"}=={"\"a\""}));assert_equal({"a",{2,3,7,"b"}},{"a",{2,3,7,"b"}});assert_equal({1,2,3},join({1},{2,3}));assert_equal({1,2,3,4},join({1},join({2},{3,4})));a={2,3};assert_equal({1,2,3,4},join({1,},join(a,{4})));assert_equal({1,2,3,4},join({1,},join({2,3},{4})));assert_equal({1,2,3},join({1,},join(a,{})));assert_equal({2,3},join({},join(a,{})));assert_equal(4,eval(compile({"+",2,2})));assert_equal("foo",eval(compile({"quote","foo"})));assert_equal({2,3},apply(join,{{2},{3}}));apply(assert_equal,{4,4});local f=function (x)return((x+1)); end ;assert_equal(2,f(1));assert_equal(3,apply(function (a,b)return((a+b)); end ,{1,2}));assert_equal({1,2},apply(function (...)local _13={...};return(_13); end ,{1,2}));assert_equal({{1,2}},apply(function (...)local _14={...};return({_14}); end ,{1,2}));assert_equal({1,2},apply(function (...)local _15={...};return(join({},join(_15,{}))); end ,{1,2}));f=function (...)local _16={...};return(_16); end ;assert_equal({"a","b"},f("a","b"));local t={};t["foo"]=17;assert_equal({foo=17},t);t["bar"]=42;assert_equal({foo=17,bar=42},t);local x=0;local l={1,2,3,4,5};do local _17=0;local _18=l;while (_17<length(_18)) do local v=_18[(_17+1)];x=(x+v);_17=(_17+1); end  end assert_equal(x,15);local l2={};do local i=0;local _19=l;while (i<length(_19)) do local v=_19[(i+1)];l2[(i+1)]=v;i=(i+1); end  end assert_equal(l,l2);x=0;t={foo=10,bar=100};for k,v in pairs(t) do if (k=="foo") then x=(x+v+1); else x=(x+v+10); end  end;assert_equal(x,121);return(print((" "..passed.." passed"))); end function interactive()current_target=current_language;local execute=function (str)local form=read_from_string(str);local result=eval(compile(form));return(print(("=> "..to_string(result)))); end ;while true do local str=io.stdin:read();if str then execute(str); else break; end  end  end function usage()print("usage: x [<input> | -i | -t] [-o <output>] [-l <language>]");return(exit()); end args=arg;if (length(args)<1) then usage(); elseif (args[1]=="-i") then interactive(); elseif (args[1]=="-t") then run_tests(); else local input=args[1];local output=false;do local i=1;local _20=args;while (i<length(_20)) do local arg=_20[(i+1)];if ((arg=="-o") or (arg=="-l")) then if (length(args)>(i+1)) then i=(i+1);local arg2=args[(i+1)];if (arg=="-o") then output=arg2; else current_target=arg2; end  else print("missing argument for",arg);usage(); end  else print("unrecognized option:",arg);usage(); end i=(i+1); end  end if (output==false) then local name=sub(input,0,find(input,"."));output=(name.."."..current_target); end write_file(output,compile_file(input)); end 