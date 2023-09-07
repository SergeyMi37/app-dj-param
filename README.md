[![Repo-GitHub](https://img.shields.io/badge/dynamic/xml?color=gold&label=GitHub%20module.xml&prefix=ver.&query=%2F%2FVersion&url=https%3A%2F%2Fraw.githubusercontent.com%2Fsergeymi37%2Fapptools-django%2Fmaster%2Fmodule.xml)](https://raw.githubusercontent.com/sergeymi37/apptools-django/master/module.xml)
[![OEX-zapm](https://img.shields.io/badge/dynamic/json?url=https:%2F%2Fpm.community.intersystems.com%2Fpackages%2Fapptools-django%2F&label=ZPM-pm.community.intersystems.com&query=$.version&color=green&prefix=apptools-django)](https://pm.community.intersystems.com/packages/apptools-django)

[![Docker-ports](https://img.shields.io/badge/dynamic/yaml?color=blue&label=docker-compose&prefix=ports%20-%20&query=%24.services.iris.ports&url=https%3A%2F%2Fraw.githubusercontent.com%2Fsergeymi37%2Fapptools-django%2Fmaster%2Fdocker-compose.yml)](https://raw.githubusercontent.com/sergeymi37/apptools-django/master/docker-compose.yml)

## apptools-django
[![OEX](https://img.shields.io/badge/Available%20on-Intersystems%20Open%20Exchange-00b2a9.svg)](https://openexchange.intersystems.com/package/apptools-django) 
[![Demo](https://img.shields.io/badge/Demo%20on-Cloud%20Run%20Deploy-F4A460)](https://apptools-django.demo.community.intersystems.com/apptoolsrest/a/info)

<img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/SergeyMi37/apptools-django">

[![license](https://img.shields.io/badge/License-Apache%202.0-yellow.svg)](https://raw.githubusercontent.com/sergeymi37/apptools-django/master/LICENSE)

## What's new

Apptools-admin included Django framework support.
The project is based on a template and inspired by applications from Dmitry and Oleksandr.

![](https://raw.githubusercontent.com/SergeyMi37/apptools-django/master/doc/Screenshot_10-at.png)

## Installation DJANGO
```
git clone https://github.com/SergeyMi37/apptools-django.git
cd apptools-django
```
Create virtual environment (optional)
```
python3 -m venv dtb_venv
source dtb_venv/bin/activate 
# deactivate
```
For Windows `source venv_dj/Scripts/activate`

Install all requirements:
```
pip install -r requirements.txt
```
Create .env file in root directory and copy-paste this or just run `cp .env_example .env`, don't forget to change telegram token:
```
DJANGO_DEBUG=True
DATABASE_URL=sqlite:///db.sqlite3
TELEGRAM_TOKEN=<PASTE YOUR TELEGRAM TOKEN HERE>
ISC_Username=_system
ISC_Password=SYS
ISC_Namespace=USER
DJANGO_SUPERUSER_PASSWORD=demo
```
Run migrations to setup SQLite database:
```
python manage.py makemigrations
python manage.py migrate
```
Load test data
```
python manage.py loaddata db-test.json
```
Create a superuser `adm` with the password `demo` to get access to the admin panel:
```
python manage.py createsuperuser --noinput --username adm --email adm@localhost.com # .env DJANGO_SUPERUSER_PASSWORD=demo
```
Compile multilingual dictionaries
```
django-admin compilemessages -i dtb_venv -i src 
```
Run bot in polling mode:
```
python run_polling.py
```
If you want to open Django admin panel which will be located on `http://localhost:8000/tgadmin/`
```
python manage.py runserver
```
## Installation with ZPM

If the current ZPM instance is not installed, then in one line you can install the latest version of ZPM even with a proxy.
```
s r=##class(%Net.HttpRequest).%New(),proxy=$System.Util.GetEnviron("https_proxy") Do ##class(%Net.URLParser).Parse(proxy,.pr) s:$G(pr("host"))'="" r.ProxyHTTPS=1,r.ProxyTunnel=1,r.ProxyPort=pr("port"),r.ProxyServer=pr("host") s:$G(pr("username"))'=""&&($G(pr("password"))'="") r.ProxyAuthorization="Basic "_$system.Encryption.Base64Encode(pr("username")_":"_pr("password")) set r.Server="pm.community.intersystems.com",r.SSLConfiguration="ISC.FeatureTracker.SSL.Config" d r.Get("/packages/zpm/latest/installer"),$system.OBJ.LoadStream(r.HttpResponse.Data,"c")
```
If ZPM is installed, then ZAPM can be set with the command
```
zpm:USER>install apptools-django
```
## Installation with Docker

Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.

## Installation 
Clone/git pull the repo into any local directory

```
$ git clone https://github.com/SergeyMi37/apptools-django.git
```

Open the terminal in this directory and run:

```
$ docker-compose build
```

3. Run the IRIS container with your project:

```
$ docker-compose up -d
```

## How to Test it
Open IRIS terminal:

```
$ docker-compose exec iris iris session iris
USER>
USER>zpm
zpm:USER>install apptools-django
```
