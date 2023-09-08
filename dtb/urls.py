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
from django.conf.urls.i18n import i18n_patterns

from django.views.generic import RedirectView
#from django.conf.urls import url


#from django.conf import settings
from django.conf.urls import include, url
#from django.conf.urls.i18n import i18n_patterns
#from django.contrib import admin
#from django.conf.urls.static import static

admin.autodiscover()

#i18n_urls = (
#    #url(r'^admin/', include(admin.site.urls)),
#    url(r'^i18n/', include('django.conf.urls.i18n')),
#)


urlpatterns = [
    path('', views.index_page, name='home'),
    
    path('admin/', admin.site.urls),
    path('tgadmin/', admin.site.urls,name="tgadmin"),
    path('__debug__/', include(debug_toolbar.urls)),
    path('info/', views.index, name="index"),

    path('iris_mp/', views.iris_mp, name="iris_portal"),
    path('iris_mp_list/', views.iris_mp_list, name="iris_portal_list"),
    path('iris_info/', views.iris_info, name="iris_info"),
    path('iris_zts/', views.iris_zts, name="iris_zts"),
    path('iris_alerts/', views.iris_alerts, name="iris_alerts"),
    path('iris_ss/', views.iris_ss, name="iris_ss"),
    
    path('super_secter_webhook/', csrf_exempt(views.TelegramBotWebhookView.as_view())),
    
    path('param_index/', views.param_index, name='param-index'),
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

urlpatterns += [
    path(r'set-language/', views.set_language, name='set_language'),
]


#urlpatterns.extend(i18n_patterns(*i18n_urls, prefix_default_language=False))
#urlpatterns.extend(static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT))

