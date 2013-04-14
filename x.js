current_target="js";current_language="js";function length(x){return(x.length);}function sub(x,from,upto){if(is_string(x)){return(x.substring(from,upto));}else{return(x.slice(from,upto));}}function push(arr,x){arr[length(arr)]=x;}function join(a1,a2){return(a1.concat(a2));}function char(str,n){return(str.charAt(n));}function find(str,pattern,start){{var i=str.indexOf(pattern,start);return(((i>0)&&i));}}fs=require("fs");function read_file(filename){return(fs.readFileSync(filename,"utf8"));}function write_file(filename,data){fs.writeFileSync(filename,data,"utf8");}function print(x){console.log(x);}function exit(code){process.exit(code);}function is_string(x){return((type(x)=="string"));}function is_number(x){return((type(x)=="number"));}function is_boolean(x){return((type(x)=="boolean"));}function is_composite(x){return((type(x)=="object"));}function is_atom(x){return(!(is_composite(x)));}function is_table(x){return((is_composite(x)&&(x[0]==undefined)));}function is_list(x){return((is_composite(x)&&!((x[0]==undefined))));}function parse_number(str){{var n=parseFloat(str);if(!(isNaN(n))){return(n);}}}function to_string(x){if((x==undefined)){return("nil");}else if(is_boolean(x)){return(((x&&"true")||"false"));}else if(is_atom(x)){return((x+""));}else{var str="[";var i=0;while((i<length(x))){var y=x[i];str=(str+to_string(y));if((i<(length(x)-1))){str=(str+" ");}i=(i+1);}return((str+"]"));}}function error(msg){throw(msg);}function type(x){return(typeof(x));}function apply(f,args){return(f.apply(f,args));}unique_counter=0;function make_unique(prefix){unique_counter=(unique_counter+1);return(("_"+(prefix||"")+unique_counter));}eof={};delimiters={};delimiters["("]=true;delimiters[")"]=true;delimiters[";"]=true;delimiters[eof]=true;delimiters["\n"]=true;whitespace={};whitespace[" "]=true;whitespace["\t"]=true;whitespace["\n"]=true;function make_stream(str){var s={};s.pos=0;s.string=str;s.length=length(str);return(s);}function peek_char(s){return((((s.pos<s.length)&&char(s.string,s.pos))||eof));}function read_char(s){var c=peek_char(s);if(c){s.pos=(s.pos+1);return(c);}}function skip_non_code(s){while(true){var c=peek_char(s);if(!(c)){break;}else if(whitespace[c]){read_char(s);}else if((c==";")){while((c&&!((c=="\n")))){c=read_char(s);}skip_non_code(s);}else{break;}}}function read_atom(s){var str="";while(true){var c=peek_char(s);if((c&&(!(whitespace[c])&&!(delimiters[c])))){str=(str+c);read_char(s);}else{break;}}var n=parse_number(str);return((((n==undefined)&&str)||n));}function read_list(s){read_char(s);var l=[];while(true){skip_non_code(s);var c=peek_char(s);if((c&&!((c==")")))){push(l,read(s));}else if(c){read_char(s);break;}else{error(("Expected ) at "+s.pos));}}return(l);}function read_string(s){read_char(s);var str="\"";while(true){var c=peek_char(s);if((c&&!((c=="\"")))){if((c=="\\")){str=(str+read_char(s));}str=(str+read_char(s));}else if(c){read_char(s);break;}else{error(("Expected \" at "+s.pos));}}return((str+"\""));}function read_quote(s){read_char(s);return(["quote",read(s)]);}function read_unquote(s){read_char(s);if((peek_char(s)=="@")){read_char(s);return(["unquote-splicing",read(s)]);}else{return(["unquote",read(s)]);}}function read(s){skip_non_code(s);var c=peek_char(s);if((c==eof)){return(c);}else if((c=="(")){return(read_list(s));}else if((c==")")){error(("Unexpected ) at "+s.pos));}else if((c=="\"")){return(read_string(s));}else if((c=="'")){return(read_quote(s));}else if((c==",")){return(read_unquote(s));}else{return(read_atom(s));}}function read_from_string(str){return(read(make_stream(str)));}operators={};operators["common"]={};operators["common"]["+"]="+";operators["common"]["-"]="-";operators["common"]["*"]="*";operators["common"]["/"]="/";operators["common"]["<"]="<";operators["common"][">"]=">";operators["common"]["="]="==";operators["common"]["<="]="<=";operators["common"][">="]=">=";operators["js"]={};operators["js"]["and"]="&&";operators["js"]["or"]="||";operators["js"]["cat"]="+";operators["lua"]={};operators["lua"]["and"]=" and ";operators["lua"]["or"]=" or ";operators["lua"]["cat"]="..";function get_op(op){return((operators["common"][op]||operators[current_target][op]));}macros={};special={};function is_call(form){return(is_string(form[0]));}function is_operator(form){return(!((get_op(form[0])==undefined)));}function is_special(form){return(!((special[form[0]]==undefined)));}function is_macro_call(form){return(!((macros[form[0]]==undefined)));}function is_macro_definition(form){return((form[0]=="macro"));}function compile_args(forms,is_compile){var i=0;var str="(";while((i<length(forms))){var x=forms[i];var x1=((is_compile&&compile(x))||normalize(x));str=(str+x1);if((i<(length(forms)-1))){str=(str+",");}i=(i+1);}return((str+")"));}function compile_body(forms){var i=0;var str=(((current_target=="js")&&"{")||"");while((i<length(forms))){str=(str+compile(forms[i],true));i=(i+1);}return((((current_target=="js")&&(str+"}"))||str));}function normalize(id){var id2="";var i=0;while((i<length(id))){var c=char(id,i);if((c=="-")){c="_";}id2=(id2+c);i=(i+1);}var last=(length(id)-1);if((char(id,last)=="?")){var name=sub(id2,0,last);id2=("is_"+name);}return(id2);}function compile_atom(form){if((form=="[]")){return((((current_target=="lua")&&"{}")||"[]"));}else if((form=="nil")){return((((current_target=="js")&&"undefined")||"nil"));}else if((is_string(form)&&!((char(form,0)=="\"")))){return(normalize(form));}else{return(to_string(form));}}function compile_call(form){var fn=compile(form[0]);var args=compile_args(sub(form,1),true);return((fn+args));}function compile_operator(form){var i=1;var str="(";var op=get_op(form[0]);while((i<length(form))){str=(str+compile(form[i]));if((i<(length(form)-1))){str=(str+op);}i=(i+1);}return((str+")"));}function compile_do(forms){var body=compile_body(forms);return((((current_target=="js")&&body)||("do "+body+" end ")));}function compile_set(form){if((length(form)<2)){error("Missing right-hand side in assignment");}var lh=compile(form[0]);var rh=compile(form[1]);return((lh+"="+rh));}function compile_branch(branch,is_first,is_last){var condition=compile(branch[0]);var body=compile_body(sub(branch,1));var tr="";if((is_last&&(current_target=="lua"))){tr=" end ";}if(is_first){return((((current_target=="js")&&("if("+condition+")"+body))||("if "+condition+" then "+body+tr)));}else if((is_last&&(condition=="true"))){return((((current_target=="js")&&("else"+body))||(" else "+body+" end ")));}else{return((((current_target=="js")&&("else if("+condition+")"+body))||(" elseif "+condition+" then "+body+tr)));}}function compile_if(form){var i=0;var str="";while((i<length(form))){var is_last=(i==(length(form)-1));var is_first=(i==0);var branch=compile_branch(form[i],is_first,is_last);str=(str+branch);i=(i+1);}return(str);}function expand_function(args,body){var i=0;while((i<length(args))){if((args[i]=="...")){args=sub(args,0,i);var name=make_unique();var expr=["list","..."];if((current_target=="js")){expr=["Array.prototype.slice.call","arguments",i];}else{push(args,"...");}process_body(body,name);body=join([["local",name,expr]],body);break;}i=(i+1);}return([args,body]);}function process_body(body,vararg){var i=0;while((i<length(body))){var form=body[i];if((form=="...")){body[i]=vararg;}else if(is_list(form)){process_body(form,vararg);}i=(i+1);}}function compile_function(form){var i=0;var name="";if(is_string(form[0])){i=1;name=normalize(form[0]);}var expanded=expand_function(form[i],sub(form,(i+1)));var args=compile_args(expanded[0]);var body=compile_body(expanded[1]);var tr=(((current_target=="lua")&&" end ")||"");return(("function "+name+args+body+tr));}function compile_get(form){var object=compile(form[0]);var key=compile(form[1]);if(((current_target=="lua")&&(char(object,0)=="{"))){object=("("+object+")");}return((object+"["+key+"]"));}function compile_dot(form){var object=compile(form[0]);var key=form[1];return((object+"."+key));}function compile_not(form){var expr=compile(form[0]);var open=(((current_target=="js")&&"!(")||"(not ");return((open+expr+")"));}function compile_local(form){var lh=compile(form[0]);var keyword=(((current_target=="js")&&"var ")||"local ");if((form[1]==undefined)){return((keyword+lh));}else{var rh=compile(form[1]);return((keyword+lh+"="+rh));}}function compile_while(form){var condition=compile(form[0]);var body=compile_body(sub(form,1));return((((current_target=="js")&&("while("+condition+")"+body))||("while "+condition+" do "+body+" end ")));}function compile_list(forms,is_quoted){var i=0;var open=(((current_target=="lua")&&"{")||"[");var close=(((current_target=="lua")&&"}")||"]");var str="";while((i<length(forms))){var x=forms[i];if((is_list(x)&&(x[0]=="unquote-splicing"))){var x1=compile(x[1]);var x2=compile_list(sub(forms,(i+1)),true);open=("join("+open);close=(close+",join("+x1+","+x2+"))");break;}else{var x1=((is_quoted&&quote_form(x))||compile(x));str=(str+x1);if((i<(length(forms)-1))){str=(str+",");}i=(i+1);}}return((open+str+close));}function compile_to_string(form){if((is_string(form)&&(char(form,0)=="\""))){var str=sub(form,1,(length(form)-1));return(("\"\\\""+str+"\\\"\""));}else if(is_string(form)){return(("\""+form+"\""));}else{return(to_string(form));}}function quote_form(form){if(is_atom(form)){return(compile_to_string(form));}else if((form[0]=="unquote")){return(compile(form[1]));}else{return(compile_list(form,true));}}function compile_quote(forms){if((length(forms)<1)){error("Must supply at least one argument to QUOTE");}return(quote_form(forms[0]));}function compile_macro(form){var tmp=current_target;current_target=current_language;eval(compile_function(form,true));var name=form[0];var register=["set",["get","macros",compile_to_string(name)],name];eval(compile(register,true));current_target=tmp;return("");}self_terminating={};self_terminating["do"]=true;self_terminating["if"]=true;self_terminating["function"]=true;self_terminating["macro"]=true;self_terminating["while"]=true;function compile_special(form,is_stmt){var name=form[0];var is_delim=(is_stmt&&!(self_terminating[name]));var delim=((is_delim&&";")||"");var fn=special[name];return((fn(sub(form,1))+delim));}special["do"]=compile_do;special["set"]=compile_set;special["get"]=compile_get;special["dot"]=compile_dot;special["not"]=compile_not;special["if"]=compile_if;special["function"]=compile_function;special["macro"]=compile_macro;special["local"]=compile_local;special["while"]=compile_while;special["list"]=compile_list;special["quote"]=compile_quote;function compile(form,is_stmt){var delim=((is_stmt&&";")||"");if((form==undefined)){return("");}else if(is_atom(form)){return((compile_atom(form)+delim));}else if(is_call(form)){if(is_operator(form)){return((compile_operator(form)+delim));}else if(is_special(form)){return(compile_special(form,is_stmt));}else if(is_macro_call(form)){var fn=macros[form[0]];var form=fn(sub(form,1));return(compile(form,is_stmt));}else{return((compile_call(form)+delim));}}else{error(("Unexpected form: "+to_string(form)));}}function compile_file(filename){var form;var output="";var s=make_stream(read_file(filename));while(true){form=read(s);if((form==eof)){break;}output=(output+compile(form,true));}return(output);}passed=0;function assert_equal(a,b){var sa=to_string(a);var sb=to_string(b);if(!((sa==sb))){error((" failed: expected "+sa+" was "+sb));}else{passed=(passed+1);}}function run_tests(){print(" running tests...");assert_equal(18,18);assert_equal(123,123);assert_equal(0.123,0.123);assert_equal(17,(16+1));assert_equal(4,(7-3));assert_equal(5,(10/2));assert_equal(6,(2*3));assert_equal(true,!(false));assert_equal(true,(true||false));assert_equal(false,(true&&false));assert_equal(17,((true&&17)||18));assert_equal(18,((false&&17)||18));assert_equal("foo","foo");assert_equal("\"bar\"","\"bar\"");assert_equal(1,length("\""));assert_equal(2,length("a\""));assert_equal("foobar",("foo"+"bar"));assert_equal(2,length(("\""+"\"")));assert_equal("a","a");assert_equal("a","a");assert_equal([],[]);assert_equal([1],[1]);assert_equal(["a"],["a"]);assert_equal(["a"],["a"]);assert_equal(false,(["a"]==["\"a\""]));assert_equal(5,length([1,2,3,4,5]));assert_equal(3,length([1,[2,3,4],5]));assert_equal(3,length([1,[2,3,4],5][1]));var a="bar";assert_equal([1,2,"bar"],[1,2,a]);assert_equal(false,("\"a\""=="a"));assert_equal(false,(["a"]==["\"a\""]));assert_equal(["a",[2,3,7,"b"]],["a",[2,3,7,"b"]]);assert_equal([1,2,3],join([1],[2,3]));assert_equal([1,2,3,4],join([1],join([2],[3,4])));a=[2,3];assert_equal([1,2,3,4],join([1,],join(a,[4])));assert_equal([1,2,3,4],join([1,],join([2,3],[4])));assert_equal([1,2,3],join([1,],join(a,[])));assert_equal([2,3],join([],join(a,[])));assert_equal([2,3],apply(join,[[2],[3]]));apply(assert_equal,[4,4]);var f=function (x){return((x+1));};assert_equal(2,f(1));assert_equal(3,apply(function (a,b){return((a+b));},[1,2]));assert_equal([1,2],apply(function (){var _1=Array.prototype.slice.call(arguments,0);return(_1);},[1,2]));print((" "+passed+" passed"));}function repl(){current_target=current_language;var execute=function (str){var form=read_from_string(str);form=["print",["cat","\"=> \"",["to-string",form]]];return(eval(compile(form)));};{process.stdin.resume();process.stdin.setEncoding("utf8");process.stdin.on("data",execute);}}function usage(){print("usage: x [<input> | -i | -t] [-o <output>] [-l <language>]");exit();}args=sub(process.argv,2);if((length(args)<1)){usage();}else if((args[0]=="-i")){repl();}else if((args[0]=="-t")){run_tests();}else{var input=args[0];var output=false;var i=1;while((i<length(args))){var arg=args[i];if(((arg=="-o")||(arg=="-l"))){if((length(args)>(i+1))){i=(i+1);var arg2=args[i];if((arg=="-o")){output=arg2;}else{current_target=arg2;}}else{print("missing argument for",arg);usage();}}else{print("unrecognized option:",arg);usage();}i=(i+1);}if((output==false)){var name=sub(input,0,find(input,"."));output=(name+"."+current_target);}write_file(output,compile_file(input));}