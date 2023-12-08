#!/bin/bash
project_domain=""
project_path=`pwd|sed "s~/${PWD##*/}~~"`
project_name=`pwd|tr / "\n"|tail -2|head -1`
Apps=""

read -p "Create apps(a) or create project(p)? (a or p)?" CreateApps
if [[ "$CreateApps" = "a" ]]; then
    echo "you must have active venv and be in main directory"
    read -p "Create Django App (Apps specify through a space): " Apps
    for a in $Apps
        do
            python manage.py startapp $a            
            sed -i "/INSTALLED_APPS = \[/,/\]/ s/]/    '$a',\n]/" main/settings.py
            mkdir -p $a/templates/$a
            cp ../start_4.2/templates/templates_app/content.html $a/templates/$a/content.html
            cp ../start_4.2/urls.py $a/urls.py
            sed -i "/]/i \#    path('$a/', include('$a.urls'))," main/urls.py
            sed -i "s/app_name = .*/app_name = '$a'/" $a/urls.py
        done
else

    read -p "Python interpreter (python3.8): " base_python_interpreter
    base_python_interpreter=${base_python_interpreter:-python3.8}

    read -p "Create Django App (Apps specify through a space): " Apps

    read -p "DEBUG (True): " DEBUG
    DEBUG=${DEBUG:-True}

    read -p "Your domain without protocol (127.0.0.1): " ALLOWED_HOSTS
    ALLOWED_HOSTS=${ALLOWED_HOSTS:-127.0.0.1}

    read -p "LANGUAGE_CODE (uk): " LANGUAGE_CODE
    LANGUAGE_CODE=${LANGUAGE_CODE:-uk}

    read -p "TIME_ZONE (Europe/Kiev): " TIME_ZONE
    TIME_ZONE=${TIME_ZONE:-Europe/Kiev}
    TIME_ZONE=$(echo "$TIME_ZONE" | sed -e 's~\/~\\\/~g')

    source $(which virtualenvwrapper.sh)
    mkvirtualenv $project_name --python=$base_python_interpreter
    workon $project_name

    sudo chmod g+w $VIRTUAL_ENV/bin/postactivate
    sudo echo "export HISTFILE=$project_path/history" >> $VIRTUAL_ENV/bin/postactivate
    sudo echo "export PROMPT_COMMAND='history -a'" >> $VIRTUAL_ENV/bin/postactivate
    sudo echo "export HISTCONTROL=ignoredups:erasedups" >> $VIRTUAL_ENV/bin/postactivate
    sudo chmod g-w $VIRTUAL_ENV/bin/postactivate

    pip install -U pip
    pip install -r requirements.txt
    cd ..
    django-admin startproject main
    cd main
    sed -i "/INSTALLED_APPS = \[/,/\]/ s/]/\n]/" main/settings.py

    for a in $Apps
        do
            python manage.py startapp $a
            sed -i "/INSTALLED_APPS = \[/,/\]/ s/]/    '$a',\n]/" main/settings.py
            mkdir -p $a/templates/$a
            cp ../start_4.2/templates/templates_app/content.html $a/templates/$a/content.html
            cp ../start_4.2/urls.py $a/urls.py
            sed -i "/]/i \#    path('$a/', include('$a.urls'))," main/urls.py
            sed -i "s/app_name = .*/app_name = '$a'/" $a/urls.py
        done

    sed -i "/django.urls/s/$/, include/" main/urls.py

    mkdir templates
    cp ../start_4.2/templates/base.html templates/base.html
    cp ../start_4.2/.gitignore_start ./.gitignore
    touch main/local_settings.py
    sed -i "/DEBUG = .*/s/DEBUG = .*/DEBUG = $DEBUG/" main/settings.py
    for a in $ALLOWED_HOSTS
        do
            ALLOWED_HOSTS_ALL="$ALLOWED_HOSTS_ALL'$a', "
        done
    sed -i "/ALLOWED_HOSTS = .*/s/].*/$ALLOWED_HOSTS_ALL]/" main/settings.py

    sed -i "/LANGUAGE_CODE = .*/s/LANGUAGE_CODE = .*/LANGUAGE_CODE = '$LANGUAGE_CODE'/" main/settings.py
    sed -i "/TIME_ZONE = .*/s/TIME_ZONE = .*/TIME_ZONE = '$TIME_ZONE'/" main/settings.py
    sed -i "/'DIRS': /s/],/\n            BASE_DIR \/ 'templates'\n        ],/" main/settings.py
    sed -i "/STATIC_URL/a STATICFILES_DIRS = [BASE_DIR / 'static',\n]" main/settings.py

    sed '/import/,+11!d' main/settings.py >> main/local_settings.py
    sed '/# Database/,+8!d' main/settings.py >> main/local_settings.py

    sed -i '/keep the secret key/,+2d' main/settings.py
    sed -i '/# Database/,+10d' main/settings.py
    sed -i "$ a \\\ntry:\n    from .local_settings import *\nexcept ImportError:\n    pass" main/settings.py

    #media

    #GULP

    read -p "Gulp App (Apps specify through a space) (all): " Apps
    Apps=${Apps:-gulp gulp-file-include gulp-sass sass gulp-autoprefixer gulp-clean-css gulp-rename gulp-imagemin@7.1.0 browser-sync del gulp-uglify-es}

    cp -r ../start_4.2/src src
    cp ../start_4.2/package.json package.json
    cp ../start_4.2/gulpfile.js gulpfile.js
    npm install --save-dev $Apps

    python manage.py migrate
    python manage.py createsuperuser
    
    pip freeze > requirements.txt

    git init
    git add --all
    git commit -m "Initial commit"

    # sublime tex project
    touch "$project_name.sublime-project"
    echo "{
    \"folders\":
    [
        {
            \"path\": \".\",
        },
        {
            \"path\": \"$VIRTUAL_ENV/lib/$base_python_interpreter/site-packages\"
        },
    ],
}" >> "$project_name.sublime-project"

fi
    #sed -i "s~dbms_template_path~$project_path~g" nginx/site.conf systemd/gunicorn.service
    #sed -i "s~dbms_template_domain~$project_domain~g" nginx/site.conf src/config/settings.py

    #sudo ln -s $project_path/nginx/site.conf /etc/nginx/sites-enabled/
    #sudo ln -s $project_path/systemd/gunicorn.service /etc/systemd/system/

    #sudo systemctl daemon-reload
    #sudo systemctl start gunicorn
    #sudo systemctl enable gunicorn
    #sudo service nginx restart
