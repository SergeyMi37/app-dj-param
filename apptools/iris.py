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
        #_val = f'{"status":"FAIL Iris connection {ISC_Host}, {ISC_Port}, {ISC_Namespace}, {ISC_Username}, {ISC_Password}"}'
        _val = '{"status":"FAIL Iris connection "}'
    return _val

def Iris4Footer(user):
    try:
        _args=f"{user},{user.is_authenticated},{user.is_authenticated}"
        print("----------",_args)
        _val=classMethod("apptools.core.telebot", "GetFooter", _args)
        print("----------",_val)
    except:
        _val = 'Error Iris4Footer :'+str(user)
    return _val

    '''
Python 3.8.10 (default, Jun 23 2021, 15:19:53)
>>>
>>> import irisnative
>>> connection = irisnative.createConnection("a3011d1fe174", int(1972), "USER", "superuser", "SYS")
>>> appiris = irisnative.createIris(connection)
>>> nodeVal = str(appiris.classMethodValue("apptools.core.telebot", "TS", ""))
>>> print(nodeVal)
>>>
    '''