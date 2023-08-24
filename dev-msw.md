# useful commands
## django ---------------------------------------------------------------
```
python -m venv dtb_venv
source dtb_venv/bin/activate
source dtb_venv/Scripts/activate # for Windows
pip install -r requirements.txt

wget --continue https://github.com/intersystems-community/iris-driver-distribution/raw/main/DB-API/intersystems_irispython-3.2.0-py3-none-any.whl &&     pip install intersystems_irispython-3.2.0-py3-none-any.whl &&     rm intersystems_irispython-3.2.0-py3-none-any.whl

# pip install apptools/api/intersystems_irispython-3.2.0-py3-none-any.whl
python -m pip install --upgrade pip
python manage.py makemigrations #<name>
python manage.py migrate
python manage.py createsuperuser --noinput --username adm --email adm@localhost.com
# python run_polling.py
python manage.py runserver

python -m venv dtb_venv && source dtb_venv/Scripts/activate && pip install -r requirements.txt
python manage.py makemigrations && python manage.py migrate && python manage.py runserver 8081

## docker ------------------------------------------------------------------
### stoped and clean all containers
docker stop $(docker ps -a -q) &&  docker rm $(docker ps -a -q) && docker system prune -f
### rmi images
docker rmi $(docker images -a -q) && docker system prune -f
### clean up docker 
```
docker system prune -f
```
### start container with iris
```
$ docker-compose up -d
```
docker-compose up --build -d
```
### build container with no cache
```
docker-compose build --no-cache --progress=plain
```
### open terminal to docker
```
docker-compose exec iris iris session iris -U IRISAPP
```
## git ------------------------------------------------------------------
### commit and push
```
git add *
git commit -am "upd"
git push
```
## git stored
```
git config --global credential.helper "cache --timeout=86400"
git config --global credential.helper store
```
```
git stash
git stash pop
git stash drop
```
```
git config --global credential.helper store
git config --global user.name "SergeyMi37"
git config --global user.email "Sergey.Mikhaylenko@gmail.com"
```

## export IRIS Analytics artifacts
```
d ##class(dev.code).export("*.DFI")
```
## build cube
```
do ##class(%DeepSee.Utils).%BuildCube("CubeName")
```
## export globals
```
do $System.OBJ.Export("po*.GBL","/irisdev/app/src/gbl/globals.xml",,.errors)
zw errors
```


## zpm --------------------------------------------------------------------
## Installed zpm short one line
```
s r=##class(%Net.HttpRequest).%New(),proxy=$System.Util.GetEnviron("https_proxy") Do ##class(%Net.URLParser).Parse(proxy,.pr) s:$G(pr("host"))'="" r.ProxyHTTPS=1,r.ProxyTunnel=1,r.ProxyPort=pr("port"),r.ProxyServer=pr("host") s:$G(pr("username"))'=""&&($G(pr("password"))'="") r.ProxyAuthorization="Basic "_$system.Encryption.Base64Encode(pr("username")_":"_pr("password")) set r.Server="pm.community.intersystems.com",r.SSLConfiguration="ISC.FeatureTracker.SSL.Config" d r.Get("/packages/zpm/latest/installer"),$system.OBJ.LoadStream(r.HttpResponse.Data,"c")

zn "%SYS" d ##class(Security.SSLConfigs).Create("z") s r=##class(%Net.HttpRequest).%New(),r.Server="pm.community.intersystems.com",r.SSLConfiguration="z" d r.Get("/packages/zpm/latest/installer"),$system.OBJ.LoadStream(r.HttpResponse.Data,"c")

zpm "generate d:\_proj\_mygirhub\isc-apptools-lockdown-2\isc-apptools-lockdown\src\ -export 00000,appmsw"
```

## .bashrc ----------------------------------------------------------------------
### User specific aliases and functions
```
alias mc="mc -S dark"
alias hi="history"
alias myip='wget -qO myip http://www.ipchicken.com/; grep -o "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}" myip;  rm myip'
export PATH=$PATH:/opt/libreoffice6.4/program
```

### PgUp/PgDn
### https://qastack.ru/programming/4200800/in-bash-how-do-i-bind-a-function-key-to-a-command
```
if [[ $- == *i* ]]
then
    bind '"\e[5~": history-search-backward'
    bind '"\e[6~": history-search-forward'
fi
```
### f12
```
bind '"\e[24~":"pwd\n"'
```
## wsl ----------------------------------------------------------
https://docs.microsoft.com/ru-ru/windows/wsl/basic-commands
https://ab57.ru/cmdlist/wslcmd.html

### start docker and ssh
```
sudo service docker start && sudo /etc/init.d/ssh restart
```
### show list
```
wsl --list -v
```
### export to tar
```
wsl --export Ubuntu20.04 d:\wsl\wsl-backup\Ubuntu20-mc-dock.tar
```
### import from tar
```
wsl --import Ubu20 d:\wsl\Ubu20 d:\wsl\wsl-backup\curr-Ubuntu20.tar
```
### terminate
```
wsl -t Ubuntu
```
### shutdown all
```
wsl -shutdown
```
### set default
wsl --set-default Ubu20.04-mc-dock

wsl --distribution Ubu20.04 --user msw
