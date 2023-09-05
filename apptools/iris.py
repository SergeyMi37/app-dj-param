import irisnative
import os
from django.conf import settings
from dtb.settings import DEBUG
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

def classMethod(request,_class,_method, _arg):
    try:
        _args=f"{request.user}|{request.user.is_authenticated}|{request.user.is_authenticated}|{request.build_absolute_uri()}|{settings.BASE_DIR}"
        connection = irisnative.createConnection(ISC_Host, int(ISC_Port), ISC_Namespace, ISC_Username, ISC_Password)
        #iris_native = irisnative.createIris(connection)
        appiris = irisnative.createIris(connection)
        _val = str(appiris.classMethodValue(_class, _method, _args))
    except Exception as err:
        print("-err-cm--------",err)
        _val = "{"+ f'"status":"Error FAIL Iris connection {err}"' +"}"
    return _val

def classMethodFooter(request):
    if DEBUG:print('-uri--',request.build_absolute_uri())
    try:
        #_args=f"{request.user}|{request.user.is_authenticated}|{request.user.is_authenticated}|{request.build_absolute_uri()}|{settings.BASE_DIR}"
        _val=classMethod(request,"apptools.core.telebot", "GetFooter", "")
        #if DEBUG:print('-ret_val-----',_val)
    except Exception as err:
        #print("-err-fo------args--",_args)
        print("-err-fo--------",err)
        _val = "{"+ f"'status':'Error Iris4Footer :{err}" +"}"
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