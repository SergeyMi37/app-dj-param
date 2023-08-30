<?xml version="1.0" encoding="UTF-8"?>
<Export generator="IRIS" version="26" zv="IRIS for Windows (x86-64) 2022.1.1 (Build 374U)" ts="2023-08-30 23:23:10">
<Class name="apptools.core.rest">
<Description>
// The REST interface: class that routes HTTP requests</Description>
<IncludeCode>apptools.core</IncludeCode>
<Super>%CSP.REST</Super>
<TimeChanged>66716,83237.8054914</TimeChanged>
<TimeCreated>65607,76511.09225</TimeCreated>
<DependsOn>apptools.core.msg</DependsOn>

<Parameter name="CONTENTTYPE">
<Default>application/json</Default>
</Parameter>

<Parameter name="CHARSET">
<Default>UTF-8</Default>
</Parameter>

<Parameter name="ISCPREFIX">
<Default>isc_cache</Default>
</Parameter>

<Parameter name="GN">
<Default>^%apptools.Task</Default>
</Parameter>

<XData name="UrlMap">
<XMLNamespace>http://www.intersystems.com/urlmap</XMLNamespace>
<Data><![CDATA[
<Routes>
<Route Url="/a/:text" Method="GET" Call="apptools.lte.adminStatic:GetMain"/>
<Route Url="/ad/:text" Method="GET" Call="apptools.MVK.adminStatic:GetMvkApp"/>

<Route Url="/get-html/:text" Method="GET" Call="Index"/>
<Route Url="/post-json" Method="POST" Call="jsonrpc"/>
<Route Url="/get-files/:text" Method="GET" Call="Files"/>

<Route Url="/testpost" Method="POST" Call="Test"/>
<Route Url="/testget/:text" Method="GET" Call="Test"/>  
<Route Url="/finduser/:text" Method="GET" Call="FindUser"/>

<Route Url="/auth" Method="GET" Call="Auth"/>
<Route Url="/css/index.css" Method="GET" Call="GetCss"/>
<Route Url="/css/themes/:theme" Method="GET" Call="GetTheme"/>
<Route Url="/js/index.js" Method="GET" Call="GetJs"/>

<Route Url="/db" Method="GET" Call="getDBsize"/>
<Route Url="/dirsize/:path" Method="GET" Call="getDirSize"/>

<Route Url="/products/:mode" Method="GET" Call="getProductions"/>
<Route Url="/productslist/:ns" Method="GET" Call="getListErrProducts"/>
<Route Url="/alerts/:count" Method="GET" Call="GetAlerts"/>
<Route Url="/status-journal/:count" Method="GET" Call="GetJourSysSummary"/>
<Route Url="/custom-task/:namespace/:args" Method="GET" Call="CustomTask"/>

<Route Url="/proj/:proj/:metrics/:mode" Method="GET" Call="apptools.MVK.Metrics:getProj"/>
</Routes>
]]></Data>
</XData>

<Method name="CustomTask">
<Description>
http://iris-test:52773/apptoolsrest/custom-task/user/test 
http://iris-test:52773/apptoolsrest/custom-task/user/get-item 
https://appadmin.demo.community.intersystems.com/apptoolsrest/custom-task/user/zpm-repo-zapm
do ##class(apptools.core.rest).CustomTask(1)</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>ns,par="10"</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	new $namespace
	set gn=..#GN
	set st=$$$OK
	set json = {}
	try {
		if $zconvert(ns,"L")="_sys" set ns="%SYS"
		set $namespace=ns
		/// http://iris-test:52773/apptoolsrest/custom-task/test
		if $G(par)="test" {
			set json.status="OK test"
			set json.array = []
			do ..AddNodeJson(json,$wc($zhex("2705")),"Run: "_par)
			quit
		}
		if $p($G(par),"-",1,2)="zpm-repo" {
			set json.status="OK "_par
			set name=$p($G(par),"-",3,*)
			if name="" set name="-/all"
			set url="https://pm.community.intersystems.com/packages/"_name
			set st=##class(apptools.core.net).GetHttp(url,.out2)
			if 'st set json.status=$System.Status.GetErrorText(st) quit
			;set st=##class(apptools.core.files).Stream2String(out2("content"),.str)
			do out2("content").OutputToDevice()
			kill json
			;set json.repo={}.$$$jsonFromJSON(str)
			quit
		}
		elseif $G(par)="get-item" {
			set json.status="OK get-item"
			set json.array = []
				,task=""
			for {	set task=$o(@gn@(task),1,data) quit:task=""
				if data'="" {
					KILL jsonreturn
					set stat=##class(apptools.core.rest).RunCustomTask(data,.jsonreturn)
					set status="OK"
					if 'stat set status=$System.Status.GetErrorText(stat)
					if $d(jsonreturn),$iso(jsonreturn) set status=status_" "_jsonreturn.status
					set arg=$SYSTEM.Encryption.Base64Encode(data)
					do ..AddNodeJson(json,$wc($zhex("2705")),task_" "_status,arg)
				}
			}
			quit
		}
		elseif $e($G(par),1,4)="run&" {
			set cgi=$p(par,"run&",2,*) ;w cgi
			do ##class(apptools.core.type).ParseURL(cgi,.cgi,"&")
			set data=$lb($namespace,$g(cgi("class")),$g(cgi("met")))
			set $list(data,8)=$g(cgi("par"))
			KILL jsonreturn
			set stat=##class(apptools.core.rest).RunCustomTask(data,.jsonreturn)
			set status="OK"
			if 'stat set status=$System.Status.GetErrorText(stat)
			if $d(jsonreturn),$iso(jsonreturn) set status=status_" "_jsonreturn.status
			set json=jsonreturn
			;set json.status=status
		    quit
		}
	}
	catch ex {
	   	Set st = $g(%objlasterror, $$$OK)
	   	Set st = $$$ADDSC(st, ex.AsStatus())
	   	;set $$$AppL("MSW","req")=$System.Status.GetErrorText(st)
	   	set json = {}
	   	set json.status=$tr($System.Status.GetErrorText(st),"<>","()")_" "_$g(cgi)
	}

	if $d(json),$iso(json) do json.%ToJSON()
  	quit $$$OK
]]></Implementation>
</Method>

<UDLText name="T">
<Content><![CDATA[
/*
/// sample servise JSON-RPC 2.0 https://www.jsonrpc.org/specification

{"jsonrpc": "2.0", "result": {"likes": 123}, "id": 1}
If error:
{"jsonrpc": "2.0", "error": {"code": 666, "message": "Post not found"}, "id": "1"}
Request:
[
  {"jsonrpc":"2.0","method":"server.shutdown","params":{"server":"42"},"id":1},
  {"jsonrpc":"2.0","method":"server.remove","params":{"server":"24"},"id":2}
]
Response:
[
  {"jsonrpc":"2.0","result":{"status":"down"},"id":1}
  {"jsonrpc":"2.0","error":{"code":1234,"message":"Server not found"},"id": 2}
]
*/
]]></Content>
</UDLText>

<Method name="jsonrpc">
<Description>
post http://server:57772/rest/jsonrpc
{"jsonrpc":"2.0","method":"GetInfo","params":{"code":"5007092465"},"id":123}</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>ns="",class="",meth=""</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set sc = $$$OK
	try {
	 	;merge $$$AppL("MML","%request.Data")=%request.Data
		;set $$$AppL("MML","%request.AppData")=%request.AppData
		;set $$$AppL("MML","req")=$$$AppObJs(%request)
		;if %request.Get("Username")'="",'..Authorize(%request.Get("Username"),%request.Get("Password")) {
		; 	;set %response.Status = "401 Unauthorized" quit
		; 	d ..jsonrpcError(401,"Unauthorized "_%request.Content) 
		;}
		if $isobject(%request.Content) { //POST
			d %request.Content.Rewind() 
			set json=%request.Content.Read($$$MaxStringLength) 
			set json = $ZCVT(json,"I","UTF8") 
			;s $$$AppL("MML","jsonrpc-json")=json
	 		if ($g(json)["{") {
	 			set method={}.$$$jsonFromJSON(json).method
	 			set params={}.$$$jsonFromJSON(json).params
	 			set jsonrpc={}.$$$jsonFromJSON(json).jsonrpc
	 			set id={}.$$$jsonFromJSON(json).id
	 			if jsonrpc'="2.0" w ..jsonrpcError(2,"Version not supported "_jsonrpc) q
	 			s appPar=""
	 			if method[":" { 
	 				if $p(method,":",1)'="" s ns=$p(method,":",1)
					if $p(method,":",2)'="" s class=$p(method,":",2)
					if $p(method,":",3)'="" s meth=$p(method,":",3)
					if $p(method,":",4)'="" s appPar=$p(method,":",4,*)
				}
				if ns'="" zn ns
				if $e(class,1)="^" {
					do @(meth_class_"(.par,.json)") ;??? xec public 
				} else {
					if appPar["~" {
						do ##class(apptools.core.type).ParseURL(appPar,.appPar,"~")  ;parse in array
					}
					elseif appPar["&" {
						d ##class(apptools.core.type).ParseURL(appPar,.appPar,"&")
					}
				   ;set %response.CharSet = "utf-8"
    			;	set %response.ContentType = "text/html"
    				;s appPar("params")=params
    				if $isobject(params) {
	    				d ##class(apptools.core.Action).GetElemParseForm(params.form,.appPar,"z",0)
	    				s appPar("params")=params.%ToJSON()
    				}
    				do $classmethod(class,meth,.appPar) 
					quit
					/*
					if $isobject(params.form) {
	    				d ##class(apptools.core.Action).GetElemParseForm(params.form,.appPar,"z",0)
	    				do $classmethod(class,meth,.appPar) 
    				}
    				elseif $isobject(params) {
	    				do $classmethod(class,meth,.params) 
    				}
	    			else {
		    			;d ##class(apptools.core.Action).GetElemParseForm(params.form,.appPar,"z",0)
      					do $classmethod(class,meth,.appPar) 
	    			}
					quit */
				}
				;w "{""text"":""Hello world"",""inn"":"""_params.inn_"""}" q
				;w $ZCVT(str,"O","UTF8") 
				;w resjson
	 			
	 		}
		} else {
			;s $$$AppL("MML","%request")=$$$AppObJs(%request)
			;m $$$AppL("MML","%request.Data")=%request.Data
			;m $$$AppL("MML","%request.Content")=%request.Content
			;set $$$AppL("MML","%request.AppData")=%request.AppData
			 d ..jsonrpcError(3,"Bad request "_%request.Content)
			 q
		}
	} catch ex {
		set sc = ex.AsStatus()
		;s $$$AppL("MML","jsonrpc-err")=$System.Status.GetErrorText(sc)
		d ..jsonrpcError(4,"exception: "_$zconvert($System.Status.GetErrorText(sc),"O","HTML"))
	}
	return $$$OK
]]></Implementation>
</Method>

<Method name="Authorize">
<ClassMethod>1</ClassMethod>
<FormalSpec>user,password</FormalSpec>
<ReturnType>%String</ReturnType>
<Implementation><![CDATA[	q $SYSTEM.Security.Login(user, password)
]]></Implementation>
</Method>

<Method name="jsonrpcError">
<ClassMethod>1</ClassMethod>
<FormalSpec>code,message</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	;w "{""jsonrpc"":""2.0"",""error"":{""code"":"""_code_""",""message"":"""_message_"""}}"
	Set json = $$$NewDynObj
 	s json.jsonrpc="2.0"
	s json.code=code
	s json.message=message
	$$$DynObjToJSON(json)
	q $$$OK
]]></Implementation>
</Method>

<Method name="Files">
<Description>
Method writes files.
/apptoolsrest/get-files/fileId</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>fileId</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
 s file=##class(apptools.core.DownloadCSP).GetfileName(fileId,,,.ContentType)
 ;get date modification	file
 set dh=$zu(140,2,file)
 if dh<0 set dh=$now(0)
 set date=$zd(dh, 11) _ ", "_ $zdt(dh, 2,1) _ " GMT"
 
 ;do %response.SetHeader("Last-Modified", date)
 if (%request.GetCgiEnv("HTTP_IF_MODIFIED_SINCE")=date) {
	        set %response.Status = "304 Not Modified"
	    } 
 else {
	set %response.CharSet="raw"
	;d %response.SetHeader("Expires", "0")
	;d %response.SetHeader("Accept-Ranges","bytes")

	if $g(ContentType)'="" {
		s mimetype=ContentType
	} else {
		set ext=$p(file,".",*)
		set mimetype=##class(apptools.core.filesMimeTypes).GetMimeTypes4ext(ext)
	}
	set %response.ContentType=mimetype
	
	set stream=##class(%FileBinaryStream).%New()
	set stream.Filename=file
	set size=stream.Size
	do %response.SetHeader("Content-Length",size)

	if ContentType["application/force-download" {
		set name=$p(file,$$$slash,*)
		set name=$ZCVT($ZCVT(name,"O","UTF8"),"O","URL")
		d %response.SetHeader("Content-Disposition","attachment;filename="_name)
	}

	while 'stream.AtEnd {
		set line=stream.Read()
		write line
	}
 }
  return $$$OK
]]></Implementation>
</Method>

<Method name="Test">
<ClassMethod>1</ClassMethod>
<FormalSpec>parameter</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set %response.CharSet = "utf-8"
    set %response.ContentType = "text/html"
	&html<<h1>Status: OK!</h1><pre>>
	zw %request
	zw %response
	&html<</pre>>
	quit $$$OK
]]></Implementation>
</Method>

<Method name="FindUser">
<Description>
Search users by context
http://localhost:57772/apptoolsrest/finduser/super</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>text=""</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
 i $l(text)<3 d ..jsonrpcError(5,$$$aText("Search string must be at least 3 characters","")) q $$$OK
 zn "%SYS"
 s sql="select Name,FullName,Comment,EmailAddress,Enabled,CreateDateTime,LastModifiedDateTime from Security.Users where UPPER(FullName) [ '"_$zconvert(text,"U")_"'"
	#if $$$comClassDefined("%ZEN.Auxiliary.jsonSQLProvider")
		set Provider = ##class(%ZEN.Auxiliary.jsonSQLProvider).%New()
		set Provider.sql = sql
		Set Provider.%Format = $$$formatJSONSQL
		Set Provider.maxRows = 10000
		set st = Provider.%DrawJSON()
	#else
		set st = $$$ERROR($$$GeneralError,"Class %ZEN.Auxiliary.jsonSQLProvider does not exist")
	#endif
	return st
]]></Implementation>
</Method>

<Method name="WriteStatic">
<Description>
Calls StaticContent.Write method or sends not modified header. Type have to be "css" or "js"
d ##class(apptools.core.rest).WriteStatic("html",,,,,text)</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>type:%String,ContentType:%String="",xDataClass="apptools.core.rest",ClassCSPPage="",IsCached=0,Content=""</FormalSpec>
<Implementation><![CDATA[
    #define CompileTime ##Expression("""" _ $zd($h, 11) _ ", "_ $zdt($NOW(0), 2,1) _ " GMT""")
    set %response.CharSet = "utf-8"
    set %response.ContentType = $case(type,
        "css": "text/css",
        "js": "text/javascript",
        "html": "text/html",
        : $case(ContentType="", 1:"text/plain", :ContentType)
    )
    do %response.SetHeader("Last-Modified", $$$CompileTime)
    try{
		;if %request.Get("Username")'="",'..Authorize(%request.Get("Username"),%request.Get("Password")) {
		; 	set %response.Status = "401 Unauthorized" quit
		;}
	    if IsCached,(%request.GetCgiEnv("HTTP_IF_MODIFIED_SINCE")=$$$CompileTime) {
	        set %response.Status = "304 Not Modified"
	    } 
	    elseif Content'="" {
		    write Content
	    }
	    elseif ClassCSPPage'="" {
		    s param=$p(ClassCSPPage,"?",2,*)
		    s ClassCSPPage=$p(ClassCSPPage,"?")
		    s:ClassCSPPage[".cls" ClassCSPPage=$p(ClassCSPPage,".cls",1)
		    ;set $$$AppL("MMM","WriteStatic")=$lb(type,ClassCSPPage) ;$$$AppObJs(id)
		    ;set $$$AppL("MMM","%request")=$$$AppObJs(%request)
		    s method="OnPage"
		    s:ClassCSPPage[":" method=$p(ClassCSPPage,":",2,*),ClassCSPPage=$p(ClassCSPPage,":",1)
		    do:method["OnPage" $classmethod(ClassCSPPage,method,param)
	    }
	    else {
	        do ..WriteStaticContent(xDataClass,type)
	    }
    }
    catch e { 
    	write $ze
    	set %response.Status = "501 Not Implemented" ;"405 Method Not Allowed" ;"400 Bad Request"
    }
]]></Implementation>
</Method>

<Method name="GetCss">
<Description>
Method writes application CSS.</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>class</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
    do ..WriteStatic("css")
    return $$$OK
]]></Implementation>
</Method>

<Method name="GetTheme">
<Description>
Method writes application theme.</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>Theme:%String</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
    do ..WriteStatic("Theme"_$REPLACE(Theme, ".css", ""),"text/css")
    return $$$OK
]]></Implementation>
</Method>

<Method name="GetJs">
<Description>
Method writes application JavaScript.</Description>
<ClassMethod>1</ClassMethod>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
    do ..WriteStatic("js")
    return $$$OK
]]></Implementation>
</Method>

<Method name="Index">
<Description>
Method writes application HTML.</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>class</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
    do ..WriteStatic("html","","",class)
    return $$$OK
]]></Implementation>
</Method>

<Method name="WriteStaticContent">
<Description>
Write the contents of xData tag</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>Class:%String,Const:%String</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
    set obj = ##class(%Dictionary.CompiledXData).%OpenId(Class_"||"_Const)
    return:(obj = "") $$$OK
    set xdata = obj.Data
    set status = ##class(%XML.TextReader).ParseStream(xdata, .textreader)
    while textreader.Read() { if (textreader.NodeType="chars") {
        write textreader.Value
    } }
    return $$$OK
]]></Implementation>
</Method>

<Method name="getStatic">
<ClassMethod>1</ClassMethod>
<FormalSpec><![CDATA[name:%String,&Description]]></FormalSpec>
<ReturnType>%String</ReturnType>
<Implementation><![CDATA[
	set class = $case($l(name, ":"), 2:$p(name, ":"), :$classname())
	set queryName = $p(name, ":", *)
	set Description=""
	set str = ""	
	if ##class(%Dictionary.XDataDefinition).IDKEYExists(class, queryName) {
		set stream = ##class(%Stream.TmpCharacter).%New()
		for i=1:1:$$$comMemberKeyGet(class,$$$cCLASSxdata,queryName,$$$cXDATAdata) {
			do stream.WriteLine($$$comMemberArrayGet(class,$$$cCLASSxdata,queryName,$$$cXDATAdata,i))
		}
		set str = stream.Read($$$MaxLocalLength)
		set Description=$$$comMemberKeyGet(class,$$$cCLASSxdata,queryName,$$$cXDATAdescription)
		
	}
	return str
]]></Implementation>
</Method>

<Method name="getDirSize">
<Description>
To sorted sizes subdirs for Linux
kill res set res="" write ##class(apptools.core.rest).getDirSize("/opt2/isc/iris/mgr/",.res,0)</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec><![CDATA[path="",&res,minsize=10]]></FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set gn = "^||tmpfile"
	do ##class(apptools.core.files).getPathcconsole(.dir,.logname)
	if $g(path)="" set path=dir ;location of default database
	if $zv'["Linux" quit $$$OK  ;for other OS not implemented
	set st=$$$OK
	set curNs=$zu(5)
	zn "%sys"
	set prefix = ..#ISCPREFIX_"_dirsize"
	set tempfile=$SYSTEM.Util.InstallDirectory()_"mgr/Temp/dirsize.log"
	kill @gn set nl = $c(10)
	try {
		;du -sm /opt2/isc/iris/mgr/*| sort -nr
		set cmd="du -sm "_path_"*| sort -nr >"_tempfile
		set result = $zf(-1, cmd)
		if (result '= 0) { 
			w !,$System.Status.GetErrorText(result)
			$$$ThrowStatus($$$ERROR($$$GeneralError, "Error:" _ result_", "_cmd)) 
		}
		else {
			set size=##class(apptools.core.files).File2Arr(tempfile,gn,"RSK\UTF8\")
			for i=1:1 { q:'$d(@gn@(i))   ;pass the loop through the entire report
				continue:$p(@gn@(i),$c(9))'>minsize ;eliminate small and empty directories
				set str=$g(@gn@(i))
				if $d(res) s res(i)=$P(str,$c(9),2)_" "_$P(str,$c(9),1)
				else  w prefix_"_"_$P(str,$c(9),2)_" "_$P(str,$c(9),1)_nl
			}
		}
	} catch ex {
		set st = ex.AsStatus()
		;$$$TRACE($system.Status.GetErrorText(st))
	}
	do ##class(%File).Delete(tempfile)
	zn curNs
	quit st
]]></Implementation>
</Method>

<Method name="getDBsize">
<Description>
The size of the database in Gigabytes
do ##class(apptools.core.rest).getDBsize("dbsize",.list) write list</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>prefix=..#ISCPREFIX_"_dbsize",dbname,int=1,all=0</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set nl = $c(10)
	new $namespace
	set $namespace="%sys"
	set gn="^||db"
	set st=##class(apptools.core.sys).SaveQuery("SYS.Database:FreeSpace",gn)
	set r=$q(@gn@("")) ;to the first link
	set r=$na(@gn@($qs(r,1),$qs(r,2))) ;take the first 2 of the index in the link
	s listDb=##class(apptools.core.sys).ListDB(.info,"NotPre,NotTemp")
	for i=1:1 { q:'$d(@r@(i))   ;pass the loop through the entire report
		continue:$g(@r@(i,1))=""
		;by default, we give all sizes to Gigabytes

		set dir=$g(@r@(i,2))
		set name=$g(@r@(i,1))
		if 'all,(","_listDb_",")'[(","_name_",") continue
		if 'all,(dir)[("secondary/")||((dir)[("temp/")) continue
		
		set size=$$ToGB($g(@r@(i,4)))
		set free=$$ToGB($g(@r@(i,8)))
		set dbname(dir)=size
		set dbname(dir,"name")=name
		set dbname(dir,"free")=free
		write:'int prefix_"_"_name_" "_size_nl
		write:'int prefix_"_"_name_"_DiskFreeSpace "_(+free)_nl
	}
	set dbname=free
	write nl
	quit $$$OK
ToGB(size) 
		if size["MB" {s size=$j(size/(1024),"",3) ;if in MB, then divide
		}
		elseif size["TB" {s size=size*1024  ;if TB then multiply
		}
		else {
			set size=+size  ;if GB then translate into the number
		}
	quit size
]]></Implementation>
</Method>

<Method name="getListErrProducts">
<Description>
http://localhost:57772/apptoolsrest/productslist/-SPGZ</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>nspace=""</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	;d ##class(apptools.core.Production).GetListErrProducts(1,nspace)
	do ##class(apptools.core.Production).GetStatusProductsJson(1,"list-errors"_nspace,.res)
	do res.%ToJSON()
	q $$$OK
]]></Implementation>
</Method>

<Method name="getProductions">
<Description>
http://localhost:57772/apptoolsrest/products/0</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>day="1"</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	if 'day {
		do ##class(apptools.core.Production).GetStatusProductsJson(0,"system-stat",.res) 
		do res.%ToJSON()
	}
	else {
		do ##class(apptools.core.Production).GetStatusProductsJson(day,"count-errors",.res)
		 do res.%ToJSON()
	}
	;d ##class(apptools.core.Production).GetStatusProducts(day,.errors)
	;s ns=""
	;for { s ns=$o(errors(ns)) q:ns=""
	;	s co=+$g(errors(ns,"CountErrors"))
	;	w $s(co:"/",1:"\")_"server_"_$zu(110)_"_"_ns_" Errors: "_co_$$$NL
	;}
	q $$$OK
]]></Implementation>
</Method>

<Method name="GetAlertsSys">
<Description>
do ##class(%SYS.System).WriteToConsoleLog("InterSystems Interoperability Test",,3)
do ##class(apptools.core.rest).GetAlertsSys(,.json)</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec><![CDATA[count=10,&sys,write=1]]></FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	do ##class(%SYSTEM.Monitor).GetAlerts(,.str,.last)
	set sys = {}
	set sys.host = $ZU(110)
	set sys.instance = $P($ZU(86),"*",2)
	set sys.version = $zv
	set sys.alerts = []
	
	set i=""
	for ii=1:1 { set i=$Order(str(i),-1,val) quit:i=""
		if ii>count quit
		set alert={}
		set alert.type=$P(val," ",3)
		set alert.text=val
		do sys.alerts.%Push(alert)
	}
	do:write sys.%ToJSON()
 quit $$$OK
]]></Implementation>
</Method>

<Method name="AddNodeJson">
<Description>
do ##class(apptools.core.rest).AddNodeJson(jsom,"g","test")</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>obj,icon="",text="",arg=""</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	set arr={}
	set arr.icon=icon ;"y" ;yellow, green, red, - HR
	set arr.text=text
	if arg'="" set arr.arg=arg
	do obj.array.%Push(arr)
	quit $$$OK
]]></Implementation>
</Method>

<Method name="CustomTaskTest">
<Description><![CDATA[
Test custom module
set ^%apptools.Task("test")=$lb($namespace,"apptools.core.rest","CustomTaskTest")
set ^%apptools.Task("show_logs")=$lb($namespace,,,,"http://iris-test:52773/apptoolsrest/custom-task/test?a=1&b=2","username","pas$w0rd")]]></Description>
<ClassMethod>1</ClassMethod>
<FormalSpec><![CDATA[par="10",&json]]></FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	new $namespace
	set gn=..#GN
	set st=$$$OK
	try {
		set json.status=json.status_"- OK - Custom Task Test -"
		set json.array = []
		do ..AddNodeJson(json,$wc($zhex("2705")),"Run: CustomTaskTest "_$g(par))
		do ..AddNodeJson(json,"g","Test1:   <b>Тест</b>")
		do ..AddNodeJson(json,"y","Test2:   <b>Тест</b>")
		do ..AddNodeJson(json,"r","Test3:   <b>Тест</b>")
		do ..AddNodeJson(json,"")
		set digit=""
		for i=0:1:11 set digit=digit_##class(apptools.core.type).UD(i)_","
		do ..AddNodeJson(json,"-",digit)
		quit
	}
	catch ex {
	   	Set st = $g(%objlasterror, $$$OK)
	   	Set st = $$$ADDSC(st, ex.AsStatus())
	   set json.status=json.status_$tr($System.Status.GetErrorText(st),"<>")
	}
  	quit $$$OK
]]></Implementation>
</Method>

<Method name="RunCustomTask">
<Description>
set st=##class(apptools.core.rest).RunCustomTask(data,.json)</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec><![CDATA[data,&json]]></FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	new $namespace
	set gn=..#GN
	set st=$$$OK
	set json = {}
	try {	
		set ns=$lg(data,1)
		set:ns'="" $namespace=ns
		set class=$lg(data,2)
		set met=$lg(data,3)
		set routine=$lg(data,4)
		set url=$lg(data,5)
		if url'="" {
			set user=$lg(data,6)
			set pass=$lg(data,7)
			if ##class(apptools.core.net).GetHttp(url,.out2,,,user, pass) {
				set stream1=out2("content")
				set status=$g(out2("status"))
				do stream1.Rewind() 
				set ret=""
				while '(stream1.AtEnd) {
					set ret=ret_stream1.ReadLine()
				}
			 	set json={}.%FromJSON(ret)
			}
		}
		elseif routine'="" {
			;TODO
		}
		elseif met'="" {
			set param=$lg(data,8)
			set st=$classmethod(class,met,$g(param),.json)
			set run=1					
		}
	}
	catch ex {
	   	Set st = $g(%objlasterror, $$$OK)
	   	Set st = $$$ADDSC(st, ex.AsStatus())
	   	;set $$$AppL("MSW","req")=$System.Status.GetErrorText(st)
	   	set json = {}
	   	set json.status=$tr($System.Status.GetErrorText(st),"<>","()")
	}
  	quit $$$OK
]]></Implementation>
</Method>

<Method name="GetJourSysSummary">
<Description>
do ##class(apptools.core.rest).GetJourSysSummary(1)</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>par="10"</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	new $namespace
	set $namespace="%SYS"
	set gn="^||tmp",q="%SYS.Journal.System:Summary"
  	set st=##class(apptools.core.sys).sql2gn(q,"q",gn)
  	;w st zw @gn q 1
  	set div=$wc($zhex("27A1")) ; 27A1 black rightwards arrow   ; 2797 heavy division sign
	set sys = {}
	set sys.status="OK"
	set sys.array = []
	do ..AddNodeJson(sys,$wc($zhex("2705")),"<b>"_$ZU(110)_", inst: "_$P($ZU(86),"*",2)_"</b> <u>"_$$$NL_$zv_"</u>")
	for i=1:1 { quit:'$d(@gn@(q,0,i))
		set arr={}
		do ..AddNodeJson(sys,"g",$GET(@gn@(q,0,i,1))_":   <b>"_$GET(@gn@(q,0,i,2))_"</b>")
		if i=8 set sys.status=$GET(@gn@(q,0,i,2))
	}
	do ##class(apptools.core.files).GetJournalFiles(par,.list,.average)
	set arr={}
	set icon="y"
	if average<4 set icon="r"
	do ..AddNodeJson(sys,icon,"Average: <u><b>"_average_"</b></u>")
	do ..AddNodeJson(sys,"-","<pre>")

	set gn="^||gn"
	d ##class(apptools.core.sys).RunCmd("df -H",gn)
	for i=1:1 { quit:'$d(@gn@(i),val)
		if i=1 set fs=$p(val,"Size")
		set icon="g"
		set perc=$p($p(val,"% /",1)," ",*)
		if perc>80 set icon="r"
		do ..AddNodeJson(sys,icon,$e(val,$l(fs),*))
	}
	do ..AddNodeJson(sys,"-","</pre>")
	do sys.%ToJSON()
  	quit $$$OK
]]></Implementation>
</Method>

<Method name="GetLastLogs">
<Description><![CDATA[
http://iris-test:52773/apptoolsrest/custom-task/user/run&class=apptools.core.rest&met=GetLastLogs&par=5
do ##class(apptools.core.rest).GetLastLogs(.par,.json)]]></Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>par=5,json</FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
	if par=(+par) {
		set sql="select top "_par_" * from apptools_core.Log order by id desc"
	}
	elseif par["!" {
		set fromDate=$p(par,"!",1)
		set toDate=$p(par,"!",2)
		set toDate=toDate_" 23:59:59"
		set sql="select * from apptools_core.Log where TimeStamp >='"_fromDate_"' and TimeStamp <='"_toDate_"' order by id desc"
	}
	;set $namespace=ns
	set gn="^||tmp"
  	set st=##class(apptools.core.sys).sql2gn(sql,,gn)

  	set div=$wc($zhex("27A1")) ; 27A1 black rightwards arrow   ; 2797 heavy division sign
	set json = {}
	set json.status="OK"
	set json.sql=sql
	set json.array = []
	;do ..AddNodeJson(json,$wc($zhex("2705")),"<b>"_$ZU(110)_", inst: "_$P($ZU(86),"*",2)_"</b> <u>"_$$$NL_$zv_"</u>")
	for i=1:1 { quit:'$d(@gn@(i))
		do ..AddNodeJson(json,"g",##class(apptools.core.sys).GetValue(gn,i,"Message")_" <b>"_##class(apptools.core.sys).GetValue(gn,i,"Arguments")_"</b>")
	}
	;do json.%ToJSON()
  	quit $$$OK
]]></Implementation>
</Method>

<Method name="SaveLog">
<Description><![CDATA[
http://iris-test:52773/apptoolsrest/custom-task/user/run&class=apptools.core.rest&met=SaveLog&par=Text-logs
http://iris-test:52773/apptoolsrest/custom-task/user/run&class=apptools.core.rest&met=SaveLog&par=Text-logs~ClassName=123~MethodName=qwe~Source=345~EventType=asd~Arguments=789
do ##class(apptools.core.rest).SaveLog("text log",.json)]]></Description>
<ClassMethod>1</ClassMethod>
<FormalSpec><![CDATA[text="",&json]]></FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
   	set json = {}
  	set Message=$wc($zhex("27A1")) ;--> arrow
  	if text["~" {
	  	do ##class(apptools.core.type).ParseURL($p(text,"~",2,*),.Par,"~")  ;parse in array
	  	set (i,ClassName, MethodName, Source, EventType, Arguments)=""
	  	set Arguments=$p(text,"~",1)
	  	for { set i=$o(Par(i),1,val) quit:i=""
	  		set @i=val
	  	}
	  	set id=##class(apptools.core.Log).AddRecord(ClassName, MethodName, Source,, Arguments, Message)
  	}
  	else {
		set id=##class(apptools.core.Log).AddRecord(,,,,text, Message)
  	}
	if id {
		set json.status="OK"
	}
	else { 
		Set st = $g(%objlasterror, $$$OK)
   		Set st = $$$ADDSC(st, ex.AsStatus())
   		;set $$$AppL("MSW","req")=$System.Status.GetErrorText(st)
   		set json.status=$tr($System.Status.GetErrorText(st),"<>","()")_" "_$g(text)
	}
  	quit $$$OK
]]></Implementation>
</Method>

<Method name="GetAlerts">
<Description>
do ##class(apptools.core.rest).GetAlerts(,.json)</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec><![CDATA[days=1,&sys]]></FormalSpec>
<ReturnType>%Status</ReturnType>
<Implementation><![CDATA[
 	;set method="class(apptools.core.files).Alert" 
	set method="class(apptools.core.files).AlertDays" 
	do ##class(apptools.core.files).FindContextInLog(days,method,.str)
	set sys = {}
	set sys.host = $ZU(110)
	set sys.instance = $P($ZU(86),"*",2)
	set sys.version = $zv
	set sys.period = $G(str)
	set sys.alerts = []
	set i=""
	for ii=1:1 { set i=$Order(str(i),-1,val) quit:i=""
		;if ii>count quit
		set alert={}
		set alert.type=$P(val," ",3)
		set alert.text=val
		do sys.alerts.%Push(alert)
	}
	do sys.%ToJSON()
	 quit $$$OK
]]></Implementation>
</Method>

<XData name="Themecache">
<Data><![CDATA[
<data>
<![CDATA[<!-- @include client/css/themes/cache.css -->]]]]><![CDATA[>
</data>
]]></Data>
</XData>

<XData name="html">
<Data><![CDATA[
<data>
<![CDATA[
<!-- @include client/index.html -->]]]]><![CDATA[>
</data>
]]></Data>
</XData>

<XData name="css">
<Data><![CDATA[
<data>
<![CDATA[<!-- @include client/css/index.css -->]]]]><![CDATA[>
</data>
]]></Data>
</XData>

<XData name="js">
<Data><![CDATA[
<data>
<![CDATA[<!-- @include client/js/index.js -->]]]]><![CDATA[>
</data>
]]></Data>
</XData>
</Class>


<Class name="apptools.core.telebot">
<Description>
Utilities for working in Telegram</Description>
<Abstract>1</Abstract>
<TimeChanged>66716,83409.2691259</TimeChanged>
<TimeCreated>64735,49528.269239</TimeCreated>

<Method name="TS">
<Description>
TimeStamp</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>val=""</FormalSpec>
<ReturnType>%String</ReturnType>
<Implementation><![CDATA[	quit $ZDT($NOW()+0,3,1,3)_" "_##class(apptools.core.type).GetValidZT($h)
]]></Implementation>
</Method>

<Method name="Alerts">
<Description>
Alerts Systems
do ##class(apptools.core.telebot).Alerts(,.json)</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>json=""</FormalSpec>
<ReturnType>%String</ReturnType>
<Implementation><![CDATA[
	do ##class(apptools.core.rest).GetAlertsSys(,.json,0)
	quit ##class(apptools.util.json).ZPretty(json,"","")
]]></Implementation>
</Method>

<Method name="SS">
<Description>
Status Systems</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>js=""</FormalSpec>
<ReturnType>%String</ReturnType>
<Implementation><![CDATA[
	set js={}
	quit $zu(110)_" "_$zv
]]></Implementation>
</Method>

<Method name="GetMe">
<ClassMethod>1</ClassMethod>
<FormalSpec>botId</FormalSpec>
<ReturnType>%DynamicObject</ReturnType>
<Implementation><![CDATA[
	s ret=..ExecuteRequest(..GetRequestObj(), "getMe",botId)
	q ret
]]></Implementation>
</Method>

<Method name="Send">
<Description>
$wc($zhex("1F6A8"))	;U+0038 U+20E3 =8;  U+0031 U+20E3 =1 ;* U+2744 snow  X - $wc($zhex("274C"))  ;https://apps.timwhitlock.info/emoji/tables/unicode
w ##class(apptools.core.telebot).Send(5111112,"13333333:AHEАWAASDDDpepSSAA","Not recognized !!! Пример кириллицы "_$wc($zhex("1F6A8")))</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>chatId:%String,botId,text:%String,obj=0</FormalSpec>
<ReturnType>%Integer</ReturnType>
<Implementation><![CDATA[
	if (obj'=0) {
		;set obj = {"remove_keyboard":true}
		set res = ..SendMessage(chatId,text,botId,obj)
	} else {
		set res = ..SendMessage(chatId,text,botId)
	}
	
	if (res.ok) {
		return res.result."message_id"
	}
	return $$$ERROR($$$GeneralError, "Error while sending a message")
]]></Implementation>
</Method>

<Method name="GetRequestObj">
<ClassMethod>1</ClassMethod>
<ReturnType>%Net.HttpRequest</ReturnType>
<Implementation><![CDATA[
	#dim request as %Net.HttpRequest
	set request = ##class(%Net.HttpRequest).%New()
	set request.Server = "api.telegram.org"
	set request.SSLConfiguration = ..CheckSSLCertificate("TelegramSSL")
	set request.Https = 1 
	return request
]]></Implementation>
</Method>

<Method name="ExecuteRequest">
<ClassMethod>1</ClassMethod>
<FormalSpec>request:%Net.HttpRequest,method:%String,botId=""</FormalSpec>
<ReturnType>%DynamicObject</ReturnType>
<Implementation><![CDATA[
	set st = request.Post("bot"_botId_"/"_method)
	if ($$$ISERR(st)) {
		throw ##class(%Exception.StatusException).CreateFromStatus(st)
	}
	return ##class(%Library.DynamicObject).%FromJSON(request.HttpResponse.Data)
]]></Implementation>
</Method>

<Method name="SendMessage">
<ClassMethod>1</ClassMethod>
<FormalSpec>chatId:%Integer,text:%String,botId,replyMarkup:%DynamicObject=0</FormalSpec>
<ReturnType>%DynamicObject</ReturnType>
<Implementation><![CDATA[
	#dim request as %Net.HttpRequest
	set request = ..GetRequestObj()
	do request.InsertFormData("chat_id",chatId)
	do request.InsertFormData("text",text)
	do request.InsertFormData("parse_mode","HTML") ;HTML ;MarkdownV2 ;Markdown https://core.telegram.org/bots/api#markdownv2-style
	
	if (replyMarkup'=0) {
		do request.InsertFormData("reply_markup",replyMarkup.%ToJSON())
	}
	return ..ExecuteRequest(request, "sendMessage",botId)
]]></Implementation>
</Method>

<Method name="GetUpdates">
<ClassMethod>1</ClassMethod>
<FormalSpec>botId,offset:%Integer="",limit:%Integer=100,timeout:%Integer=0</FormalSpec>
<ReturnType>%DynamicObject</ReturnType>
<Implementation><![CDATA[
	#dim request as %Net.HttpRequest
	set request = ..GetRequestObj()
	if (offset'="") {
		do request.InsertFormData("offset",offset)
	}
	do request.InsertFormData("limit",limit)
	do request.InsertFormData("timeout",timeout)
	return ..ExecuteRequest(request, "getUpdates",botId)
]]></Implementation>
</Method>

<Method name="CheckSSLCertificate">
<Description>
The method checks for the existence of the configured SSL configuration
and creates an empty configuration with that name if this yet
to connect to a https server, that's enough</Description>
<ClassMethod>1</ClassMethod>
<FormalSpec>name</FormalSpec>
<ReturnType>%String</ReturnType>
<Implementation><![CDATA[
  NEW $NAMESPACE
  SET $NAMESPACE = "%SYS"
  
  IF '##class(Security.SSLConfigs).Exists(name) {
    DO ##class(Security.SSLConfigs).Create(name)
  }
  QUIT name
]]></Implementation>
</Method>
</Class>
</Export>
