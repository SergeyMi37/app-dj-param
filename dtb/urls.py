"""dtb URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
import debug_toolbar
from django.contrib import admin
from django.urls import path, include
from django.views.decorators.csrf import csrf_exempt
from django.conf.urls.static import static
from django.conf import settings
from . import views

from django.views.generic import RedirectView
from django.conf.urls import url

urlpatterns = [
    path('admin/', admin.site.urls),
    path('tgadmin/', admin.site.urls,name="tgadmin"),
    path('__debug__/', include(debug_toolbar.urls)),
    path('info/', views.index, name="index"),
    path('iris_info/', views.irisinfo, name="irisinfo"),
    path('super_secter_webhook/', csrf_exempt(views.TelegramBotWebhookView.as_view())),
    
    path('', views.index_page, name='home'),
    path('params/add', views.add_param_page, name='param-add'),
    path('params/list', views.params_page, name='param-list'),
    path('params/my', views.params_page,{'my':True}, name='param-my'),
    path('param/<int:param_id>/', views.param_detail, name='param-detail'),
    path('param/<int:param_id>/delete', views.param_delete, name='param-delete'),
    path('comment/add', views.comment_add, name="comment_add"),
    path('login/', views.login_page, name='login'),
    path('logout/', views.logout_page, name='logout'),
    path('register/', views.registration, name='register'),
    #url(r'^favicon\.ico$',RedirectView.as_view(url='/static/images/logo.png')),
    path('favicon.ico', RedirectView.as_view(url='/static/apptools-admin-hammer.png')),
] + static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
