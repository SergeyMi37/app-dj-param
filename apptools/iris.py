import irisnative
import os

# For Docker
#ISC_Host=iris
#ISC_Port=1972
#ISC_Username=_system
#ISC_Password=SYS
#ISC_Namespace=USER
ISC_Host = os.getenv("ISC_Host")
ISC_Port = os.getenv("ISC_Port")
ISC_Username = os.getenv("ISC_Username")
ISC_Password = os.getenv("ISC_Password")
ISC_Namespace = os.getenv("ISC_Namespace")

def classMethod(_class,_method, _arg):
    try:
        connection = irisnative.createConnection(ISC_Host, int(ISC_Port), ISC_Namespace, ISC_Username, ISC_Password)
        iris_native = irisnative.createIris(connection)
        appiris = irisnative.createIris(connection)
        _val = str(appiris.classMethodValue(_class, _method, _arg))
        #nodeVal = str(appiris.classMethodValue("apptools.core.telebot", "TS", ""))
        #print(myIris.get("Test"))
    except:
        _val = 'FAIL Iris connection'
    return _val


    '''
  root@f154e8ae5a9a:/code# python
Python 3.8.10 (default, Jun 23 2021, 15:19:53)
[GCC 8.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>>
>>> import irisnative
>>> connection = irisnative.createConnection("a3011d1fe174", int(1972), "USER", "superuser", "SYS")
>>> appiris = irisnative.createIris(connection)
>>> nodeVal = str(appiris.classMethodValue("apptools.core.telebot", "TS", ""))
>>> print(nodeVal)
2023-08-17 06:44:29 66703,24269.988666423 --- a3011d1fe174 IRIS for UNIX (Ubuntu Server LTS for x86-64 Containers) 2023.2 (Build 227U) Mon Jul 31 2023 18:04:28 EDT
>>>
    '''