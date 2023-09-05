import json
import logging
from django.views import View
from django.http import JsonResponse
from telegram import Update

from dtb.celery import app
#from dtb.settings import DEBUG, settings
import dtb.settings
from tgbot.dispatcher import dispatcher
from tgbot.main import bot

from apptools.iris import classMethod, classMethodFooter
from django.utils.translation import ugettext as _

logger = logging.getLogger(__name__)

@app.task(ignore_result=True)
def process_telegram_event(update_json):
    update = Update.de_json(update_json, bot)
    dispatcher.process_update(update)


def index(request):
    return JsonResponse({"ok": "wellcome"})

def iris_info(request):
    return JsonResponse(json.loads(classMethod(request,"apptools.core.telebot", "TS","")))

def iris_zts(request):
    return JsonResponse(json.loads(classMethod("","apptools.core.telebot", "TS","")))

def iris_ss(request):
    return JsonResponse(json.loads(classMethod(request,"apptools.core.telebot", "SS","")))

def iris_alerts(request):
    return JsonResponse(json.loads(classMethod(request, "apptools.core.telebot", "Alerts" ,"")))
    

class TelegramBotWebhookView(View):
    # WARNING: if fail - Telegram webhook will be delivered again.
    # Can be fixed with async celery task execution
    def post(self, request, *args, **kwargs):
        if dtb.settings.DEBUG:
            process_telegram_event(json.loads(request.body))
        else:
            # Process Telegram event in Celery worker (async)
            # Don't forget to run it and & Redis (message broker for Celery)!
            # Locally, You can run all of these services via docker-compose.yml
            process_telegram_event.delay(json.loads(request.body))

        # e.g. remove buttons, typing event
        return JsonResponse({"ok": "POST request processed"})

    def get(self, request, *args, **kwargs):  # for debug
        return JsonResponse({"ok": "Get request received! But nothing done"})

###### Param
from django.http import Http404,HttpResponseRedirect
from django.shortcuts import render, redirect
from appmsw.models import Param
from appmsw.forms import ParamForm, UserRegistrationForm, CommentForm
from django.contrib import auth
from django.contrib.auth.decorators import login_required
from django.contrib import messages

@login_required
def set_language(request):
    lang = request.POST.get('lang', 'en')
    request.session[dtb.settings.LANGUAGE_SESSION_KEY] = lang
    response = HttpResponseRedirect(request.META.get('HTTP_REFERER', '/'))
    response.set_cookie(dtb.settings.LANGUAGE_COOKIE_NAME, lang)
    return response


def index_page(request):
    if request.user.is_authenticated:
        errors = []
    else:
        errors = ['password or username not correct']
  
    context = {
        'pagename': _('Param Demo'),
        "errors": errors,
        "iris_footer":json.loads(classMethodFooter(request)),
    }

    return render(request, 'pages/index.html', context)


def add_param_page(request):
    if request.method == "POST":
        form = ParamForm(request.POST)
        if form.is_valid():
            param = form.save(commit=False)
            if request.user.is_authenticated:
                param.user = request.user
            param.save()
        return redirect('param-list')
    elif request.method == "GET":
        form = ParamForm()
        context = {
            'pagename': _('Adding a new parameter'),
            "iris_footer":json.loads(classMethodFooter(request)),
            'form': form
        }
        return render(request, 'pages/add_param.html', context)


def param_detail(request, param_id):
    param = Param.objects.get(pk=param_id)
    comment_form = CommentForm()
    comments = param.comments.all()
    context = {
       'pagename': _('Options Page'),
       "iris_footer":json.loads(classMethodFooter(request)),
        "param": param,
        "comments": comments,
        "comment_form": comment_form,
    }
    return render(request, 'pages/param_page.html', context)


def param_delete(request, param_id):
    param = Param.objects.get(pk=param_id)
    param.delete()
    messages.success(request, _('Parameter deleted successfully'))
    return redirect('param-list')


def params_page(request,my=False):
    params = Param.objects.all()
    pagename=_('View parameters')
 
    if my and request.user.is_authenticated:
        params = Param.objects.filter(user=request.user)
        pagename=_("My parameters")

    param_context = request.GET.get('param_context')
    if param_context:
        #params = params.filter(name__icontains=param_context)
        #params = params.filter(Q(name__icontains=param_context)|Q(code__icontains=param_context))
        params = params.filter(name__icontains=param_context) | params.filter(code__icontains=param_context)
    count=params.count()
    context = {
        "iris_footer":json.loads(classMethodFooter(request)),
        'pagename': pagename,
        'params': params,
        'count':count
    }
    return render(request, 'pages/view_params.html', context)


@login_required()
def params_my(request):
    params = params = Param.objects.filter(user=request.user)
    context = {
        'pagename': _('My parameters'),
         "iris_footer":json.loads(classMethodFooter(request)),
        'params': params
    }
    return render(request, 'pages/view_params.html', context)


@login_required()
def comment_add(request):
   if request.method == "POST":
       comment_form = CommentForm(request.POST)
       param_id = request.POST['param_id']
       if comment_form.is_valid():
           comment = comment_form.save(commit=False)
           comment.author = request.user
           comment.param = Param.objects.get(id=param_id)
           comment.save()

       return redirect(f'/param/{param_id}')

   raise Http404

def login_page(request):
    if request.method == 'POST':
        username = request.POST.get("username")
        password = request.POST.get("password")
        user = auth.authenticate(request, username=username, password=password)
        if user is not None:
            auth.login(request, user)
    return redirect('home')


def logout_page(request):
    auth.logout(request)
    return redirect('home')


def registration(request):
    if request.method == "POST":  # Создаем пользователя
        form = UserRegistrationForm(request.POST)
        if form.is_valid():
            form.save()
            messages.success(request, 'Profile updated successfully')
            return redirect('home')
        else:
            messages.error(request, 'Error updating your profile')
            context = {'form': form}
            return render(request, 'pages/registration.html', context)
    elif request.method == "GET":  # Страницу с формой
        form = UserRegistrationForm()
        context = {'form': form}
        return render(request, 'pages/registration.html', context)
