/// Utilities for working in Telegram
Class apptools.core.telebot [ Abstract ]
{

/// Get base responce
ClassMethod GetResp(arg = "") As %String
{
	set js={}
	set js.status="ok"
	set js.instance = $ZU(86)
	set js.version=$zv
	set:arg'="" js.django={}.%FromJSON(arg)   //"AnonymousUser"
	quit js
}

/// TimeStamp
/// w ##class(apptools.core.telebot).TS(,.json)
ClassMethod TS(arg = "", js) As %String
{
	set js=..GetResp(arg)
	set js.datetime= $ZDT($NOW()+0,3,1,3)_" "_##class(apptools.core.type).GetValidZT($h)
	set js.zts= $zts
	quit ##class(apptools.util.json).ZPretty(js,"","")
}

/// Alerts Systems
/// w ##class(apptools.core.telebot).Alerts(,.json)
ClassMethod Alerts(arg = "", js = "") As %String
{
	set js=..GetResp(arg)
	do ##class(apptools.core.rest).GetAlertsSys(,.js,0)
	quit ##class(apptools.util.json).ZPretty(js,"","")
}

/// Status Systems
ClassMethod SS(arg = "", js) As %String
{
	set js=..GetResp(arg)
	quit ##class(apptools.util.json).ZPretty(js,"","")
}

/// Get Info for Footer
/// w ##class(apptools.core.telebot).GetFooter("")
ClassMethod GetFooter(arg = "", js) As %String
{
	set js=..GetResp(arg)
	try {
		if 'js.django.authenticated quit 
		do ##class(apptools.core.net).GetURI(.prop)
		do ##class(apptools.lte.info).GetTopMenuFavorites(.opt,$lb("1","name"))	
		;set ip=##class(apptools.core.net).GetIP()
		;set js.ip=ip
		set js.host=$zu(110)
		set js.webport=$g(prop("WebServerPort"))
		set js.apps = []
		set uri=js.django.absoluteuri ;request.build_absolute_uri()
		if js.django.irishost="iris",js.django.irisport="1972",##class(apptools.core.files).ReadFile("/irisdev/app/docker-compose.yml",.txt,1) { 	// if we are in the docker, then we will find the port   
			set port=$p($p(txt,":52773")," ",*)
			if port="" set port=52773
			set uri=$p(uri,":",1,2)_":"_port
		}
		elseif js.django.irishost'="iris" {
			set uri="http://"_js.django.irishost_":"_prop("WebServerPort")
		}
		set i=""
		for { set i=$o(opt(i)) quit:i=""
			set app={}
			set app.name=opt(i,"TabName")
			set app.url=uri_opt(i,"InFrameUrl")
			do js.apps.%Push(app)
		}
	}
	catch e { 
		set js.status="error "_$ze
	}
	quit ##class(apptools.util.json).ZPretty(js,"","")
}

/// Get Info for Managment Portal
/// w ##class(apptools.core.telebot).GetPortal("",.js)
ClassMethod GetPortal(arg = "", js) As %String
{
	set js=..GetResp(arg)
	try {
		if 'js.django.authenticated quit 
		set gn="^||tmpPortal"
		set %Param=js.django.arg
		set js.proc={}
		set js.proc.count=##class(apptools.core.telebot).GetPortalProc(1,gn)
		set js.lock={}
		set js.lock.count=##class(apptools.core.telebot).GetPortalLock(1,gn)
		set js.db={}
		set js.db.count=##class(apptools.core.telebot).GetPortalNS(1,gn,"Databases")
		set js.ns={}
		set js.ns.count=##class(apptools.core.telebot).GetPortalNS(1,gn,"Namespaces")
		set js.alerts={}
		do ##class(%SYSTEM.Monitor).GetAlerts(,.str,.last)
		set st=$o(str(""),-1)
		set js.alerts.count=+st
		if %Param["Namespaces" {
			do ##class(apptools.core.telebot).GetPortalNS(0,gn,"Namespaces"," ")
		}
		elseif %Param["Databases" {
			do ##class(apptools.core.telebot).GetPortalNS(0,gn,"Databases"," ")
		}
		elseif %Param["Process" {
			do ##class(apptools.core.telebot).GetPortalProc(0,gn)
		}
		elseif %Param["Locktab" {
			do ##class(apptools.core.telebot).GetPortalLock(0,gn)
		}
		elseif %Param["Alerts" {
			set i=""
			do ##class(apptools.core.sys).SetTableHeader(gn,"DataTime","PID","Level","Messages")
			for { set i=$o(str(i)) quit:i=""
				do ##class(apptools.core.sys).SetTableRow(gn,i,$p(str(i)," ",1),$p(str(i)," ",2),$p(str(i)," ",3),$p(str(i)," ",4,*))
			}
			do ##class(apptools.core.sys).SetTableFooter(gn)
			set run="set st=##class(apptools.core.LogInfoPane).DrawSQL(""r "_gn_""",10000,$zu(5),"" "",,,"""")"
			do ##class(apptools.core.sys).Run2Spool(run,gn)
		}
		set js.draw=$p($g(@gn),"</table>",1)_"</table>"
	}
	catch e { 
		set js.status="error "_$ze
	}
	quit ##class(apptools.util.json).ZPretty(js,"","")
}

/// w ##class(apptools.core.telebot).GetPortalLock(1,"^||tmpL")
ClassMethod GetPortalLock(count, gn) As %String
{
	new $namespace
	set $namespace= "%SYS" 
	do ##class(apptools.core.sys).SaveQueryTab("%SYS.LockQuery:Detail",gn)
	set run="set st=##class(apptools.core.LogInfoPane).DrawSQL(""r "_gn_""",10000,$zu(5),"" "",,,"""")"
	do ##class(apptools.core.sys).Run2Spool(run,gn,,.counts)
	if count {
		quit +$g(counts)
	}
	quit 0
}

/// do ##class(apptools.core.telebot).GetPortalProc(1,"^tmpNSoutpot","Namespaces"," ")
ClassMethod GetPortalProc(count, gn, SectionHeader = "Namespaces", %Param = " ") As %String
{
	new $namespace
	set $namespace= "%SYS" 
	if count {
		set %sql="select count(*) from %SYS.ProcessQuery"
		do ##class(apptools.core.sys).sql2gn(%sql,"",gn)
		quit +$lg($g(@gn@(1)))
	}
	else { 
		;set tabs=""
		;if SectionHeader = "Namespaces" set tabs=",Routines ,SysGlobals,SysRoutines,TempGlobals"
		set %sql="select * from %SYS.ProcessQuery"
	}
	set run="set st=##class(apptools.core.LogInfoPane).DrawSQL(%sql,10000,$zu(5),%Param,,,"""")"
	do ##class(apptools.core.sys).Run2Spool(run,gn)
	quit 0
}

/// do ##class(apptools.core.telebot).GetPortalNS(1,"^tmpNSoutpot","Namespaces"," ")
ClassMethod GetPortalNS(count, gn, SectionHeader = "Namespaces", %Param = "") As %String
{
	new $namespace
	set $namespace= "%SYS" 
	if count {
		set %sql="select count(*) from Config.Namespaces where SectionHeader = '"_SectionHeader_"'"
		do ##class(apptools.core.sys).sql2gn(%sql,"",gn)
		quit +$lg($g(@gn@(1)))
	}
	else { 
		set tabs=""
		if SectionHeader = "Namespaces" set tabs=",Routines ,SysGlobals,SysRoutines,TempGlobals"
		set %sql="select Name, Globals"_tabs_" from Config.Namespaces where SectionHeader = '"_SectionHeader_"'"
	}
	set run="set st=##class(apptools.core.LogInfoPane).DrawSQL(%sql,10000,$zu(5),%Param,,,"""")"
	do ##class(apptools.core.sys).Run2Spool(run,gn)
	quit 0
}

/// Get info from telebot
ClassMethod GetMe(botId) As %DynamicObject
{
	s ret=..ExecuteRequest(..GetRequestObj(), "getMe",botId)
	q ret
}

/// $wc($zhex("1F6A8"))	;U+0038 U+20E3 =8;  U+0031 U+20E3 =1 ;* U+2744 snow  X - $wc($zhex("274C"))  ;https://apps.timwhitlock.info/emoji/tables/unicode
/// w ##class(apptools.core.telebot).Send(5111112,"13333333:AHEАWAASDDDpepSSAA","Not recognized !!! Пример кириллицы "_$wc($zhex("1F6A8")))
ClassMethod Send(chatId As %String, botId, text As %String, obj = 0) As %Integer
{
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
}

ClassMethod GetRequestObj() As %Net.HttpRequest
{
	#dim request as %Net.HttpRequest
	set request = ##class(%Net.HttpRequest).%New()
	set request.Server = "api.telegram.org"
	set request.SSLConfiguration = ..CheckSSLCertificate("TelegramSSL")
	set request.Https = 1 
	return request
}

ClassMethod ExecuteRequest(request As %Net.HttpRequest, method As %String, botId = "") As %DynamicObject
{
	set st = request.Post("bot"_botId_"/"_method)
	if ($$$ISERR(st)) {
		throw ##class(%Exception.StatusException).CreateFromStatus(st)
	}
	return ##class(%Library.DynamicObject).%FromJSON(request.HttpResponse.Data)
}

ClassMethod SendMessage(chatId As %Integer, text As %String, botId, replyMarkup As %DynamicObject = 0) As %DynamicObject
{
	#dim request as %Net.HttpRequest
	set request = ..GetRequestObj()
	do request.InsertFormData("chat_id",chatId)
	do request.InsertFormData("text",text)
	do request.InsertFormData("parse_mode","HTML") ;HTML ;MarkdownV2 ;Markdown https://core.telegram.org/bots/api#markdownv2-style
	
	if (replyMarkup'=0) {
		do request.InsertFormData("reply_markup",replyMarkup.%ToJSON())
	}
	return ..ExecuteRequest(request, "sendMessage",botId)
}

ClassMethod GetUpdates(botId, offset As %Integer = "", limit As %Integer = 100, timeout As %Integer = 0) As %DynamicObject
{
	#dim request as %Net.HttpRequest
	set request = ..GetRequestObj()
	if (offset'="") {
		do request.InsertFormData("offset",offset)
	}
	do request.InsertFormData("limit",limit)
	do request.InsertFormData("timeout",timeout)
	return ..ExecuteRequest(request, "getUpdates",botId)
}

/// The method checks for the existence of the configured SSL configuration
/// and creates an empty configuration with that name if this yet
/// to connect to a https server, that's enough
ClassMethod CheckSSLCertificate(name) As %String
{
  NEW $NAMESPACE
  SET $NAMESPACE = "%SYS"
  
  IF '##class(Security.SSLConfigs).Exists(name) {
    DO ##class(Security.SSLConfigs).Create(name)
  }
  QUIT name
}

}

