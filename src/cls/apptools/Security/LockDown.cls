/// Security utilities
Class apptools.Security.LockDown [ Abstract ]
{

/// Increase system security to LockDown
/// The method disables services and applications as in LockDown. Deletes the namespaces "DOCBOOK", "ENSDEMO", "SAMPLES"
/// The method enables auditing and configures registration of all events in the portal, except for switching the log
/// and modification of system properties
/// For all predefined users, change the password and change the properties as in LockDown
/// 	newPassword - new single password instead of %SYS. For LockDown security level, it has an 8.32ANP pattern
/// 	sBindings = 1 Service %Service_bindings enable
/// 	sCachedirect = 1 Service %Service_cachedirect enable
/// 	InactiveLimit=90  
/// 	DemoDelete=0 Demoens,Samples namespaces are being deleted 
/// 	AuditOn=1 
/// 	sECP = 1 Service %Service_ecp enable
/// 	sBindingsIP - list of ip addresses with a semicolon for which to allow CacheStudio connection.
/// 
/// For ECP configurations, you need to add the addresses of all servers and clients to allow connection on %Net.RemoteConnection to remove "abandoned" tasks
/// 	sCachedirectIP - list of ip addresses with a semicolon for which to allow legacy applications connection.
/// 	sECPIP - list of ip addresses with a semicolon for which to allow connection to the ECP server.
/// 	AuthLDAP = 1 In addition to the password, also enable LDAP authentication
/// 	Application example:
/// 	d ##class(apptools.Security.LockDown).Apply("NewPassword123",.msg,1,1,0,0,0,0,"127.0.0.1","127.0.0.1")
/// 	d ##class(apptools.Security.LockDown).Apply("NewPassword123",.msg,1,1,0,0,1,0,"127.0.0.1","127.0.0.1",,1)
ClassMethod Apply(newPassword = "", Warn, sBindings = "", sCachedirect = "", InactiveLimit = 90, DemoDelete = 0, AuditOn = 1, sECP = "", sBindingsIP = "", sCachedirectIP = "", sECPIP = "", AuthLDAP = 0) As %Status
{
	write !,"Start Lockdown"
	set userlist=..GetPreparedUsers()
	new $namespace
	set $namespace="%SYS"
	write !,"Applications and services will be authenticated by "_$s('AuthLDAP:"password",1:"password and LDAP")
	set AutheEnabled=$s(AuthLDAP:2080,1:32) ;password
	s serviceCSP = $Select($Select($ZVersion["IRIS":1,1:0):"%service_webgateway",1:"%service_csp")
	if DemoDelete,$zv["IRIS" set DemoDelete=0	
	zn "%sys"
	if newPassword'="" {
		if newPassword'?8.32ANP s text="Password does not match the pattern 8.32ANP" write !,text QUIT $$$ERROR(text)
		write !,"Password is reset to predefined users"
		set tSC=..ChangePassword(newPassword, userlist)
		if '$$$ISOK(tSC) QUIT $$$ERROR(tSC)
		w !,"OK"
	}
	write !,"Modification of service properties:"
	set result=##CLASS(%ResultSet).%New("%DynamicQuery:SQL")
	set tSC=result.Prepare("select NameLowerCase,ClientSystems FROM Security.Services")
	set:tSC tSC=result.Execute()
	if '$$$ISOK(tSC) {
		set text="Service configuration error :"_$SYSTEM.Status.GetErrorText(tSC) write !,text
		QUIT $$$ERROR(text)
	}
	else {
		while result.Next() {
			set name=result.Data("NameLowerCase")
			#;skipping network services
			continue:(name="%service_mirror")||(name="%service_shadow")||(name="%service_datacheck")
			kill prop
			set prop("Enabled")=0
			if name=serviceCSP||(name="%service_terminal")||(name="%service_console")||(name="%service_login") {
				set prop("Enabled")=1 ; turn on
				if name'=serviceCSP s prop("AutheEnabled")=AutheEnabled
				else  s prop("AutheEnabled")=96
			}
			if $G(sBindings),name="%service_bindings" {
				set prop("Enabled")=1
				set prop("AutheEnabled")=AutheEnabled
				set Warn($i(Warn))="If the current system does not intend to develop or edit the source code in CacheStudio, then it is better to turn off the service "_name
				set prop("ClientSystems")=sBindingsIP
			}
			if $G(sCachedirect),name="%service_cachedirect" {
				set prop("Enabled")=1 ; turn on
				set prop("AutheEnabled")=96
				set Warn($i(Warn))="If the current system does not intend to legacy utility, then it is better to turn off the service "_name
				set prop("ClientSystems")=sCachedirectIP
			}
			if $G(sECP),name="%service_ecp" {
				set prop("Enabled")=1

ОШИБКА #5001: Old version

#; Exported to /iris-backup/apptools/app-iris/app20230906164922/apptools-admin/src/#; Exporting to /iris-backup/apptools/app-iris/app20230906164922/apptools-admin/src/

mkdir /iris-backup/apptools/app-iris/app20230906164922/apptools-admin/src/cls/apptools/Tabs/ 1
apptools.Tabs.Panel.cls -> cls/apptools/Tabs/Panel.cls 
ОШИБКА #5005: Невозможно открыть файл '/iris-backup/apptools/app-iris/app20230906164922/apptools-admin/src/cls/apptools/Tabs/Panel.cls'
apptools.Tabs.PanelSample.cls -> cls/apptools/Tabs/PanelSample.cls 
ОШИБКА #5005: Невозможно открыть файл '/iris-backup/apptools/app-iris/app20230906164922/apptools-admin/src/cls/apptools/Tabs/PanelSample.cls'
apptools.Tabs.PanelUikit.cls -> cls/apptools/Tabs/PanelUikit.cls 
ОШИБКА #5001: Old version
apptools.Tabs.PanelUikitAdmin.cls -> cls/apptools/Tabs/PanelUikitAdmin.cls Ok
apptools.Tabs.PanelUikitPermissions.cls -> cls/apptools/Tabs/PanelUikitPermissions.cls Ok
apptools.Tabs.PanelUikitPermissMatrx.cls -> cls/apptools/Tabs/PanelUikitPermissMatrx.cls Ok
apptools.Tabs.security.cls -> cls/apptools/Tabs/security.cls Ok

#; Exported to /iris-backup/apptools/app-iris/app20230906164922/apptools-admin/src/#; Exporting to /iris-backup/apptools/app-iris/app20230906164922/apptools-admin/src/

mkdir /iris-backup/apptools/app-iris/app20230906164922/apptools-admin/src/cls/apptools/Uikit/ 1
apptools.Uikit.Admin.cls -> cls/apptools/Uikit/Admin.cls Ok
apptools.Uikit.AdminLTE.cls -> cls/apptools/Uikit/AdminLTE.cls 
ОШИБКА #5005: Невозможно открыть файл '/iris-backup/apptools/app-iris/app20230906164922/apptools-admin/src/cls/apptools/Uikit/AdminLTE.cls'
apptools.Uikit.AdminLTEtabs.cls -> cls/apptools/Uikit/AdminLTEtabs.cls Ok
apptools.Uikit.AdminPanel.cls -> cls/apptools/Uikit/AdminPanel.cls Ok
apptools.Uikit.AdminStatic.cls -> cls/apptools/Uikit/AdminStatic.cls Ok

#; Exported to /iris-backup/apptools/app-iris/app20230906164922/apptools-admin/src/#; Exporting to /iris-backup/apptools/app-iris/app20230906164922/apptools-admin/src/

mkdir /iris-backup/apptools/app-iris/app20230906164922/apptools-admin/src/cls/apptools/Form/ 1
apptools.Form.Exp.cls -> cls/apptools/Form/Exp.cls Ok
apptools.Form.Explorer.cls -> cls/apptools/Form/Explorer.cls Ok

#; Exported to /iris-backup/apptools/app-iris/app20230906164922/apptools-admin/src/#; Exporting to /iris-backup/apptools/app-iris/app20230906164922/apptools-admin/src/

mkdir /iris-backup/apptools/app-iris/app20230906164922/apptools-admin/src/cls/apptools/Chart/ 1
apptools.Chart.Chart.cls -> cls/apptools/Chart/Chart.cls 
<DISCONNECT>ParseQualifierAlterDefault+12^%occQualifier</td>
</tr></table>
</body></html>
