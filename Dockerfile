# Dockerfile for dockerize brat application (https://brat.nlplab.org)

# base image is ubuntu 
FROM ubuntu

# in spite of -y flag in install command we should choose time zone  
ENV TZ=Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# install all requirements in non-interactive mode and clear libraries lists
# we use:
# curl for transferring data using various network protocols
# apache2 as web-server 
# python for brat scripts
# supervisor for monitoring and controlling a number of processes in OS
# rsync for synhronize files 
RUN apt-get update \
    && apt-get install -y curl apache2 python supervisor rsync\
    && rm -rf /var/lib/apt/lists/*

# create base directory for brat, download brat's archive and unzip it
RUN mkdir /var/www/brat
RUN curl http://weaver.nlplab.org/~brat/releases/brat-v1.3_Crunchy_Frog.tar.gz > /var/www/brat/brat-v1.3_Crunchy_Frog.tar.gz 
RUN cd /var/www/brat && tar -xvzf brat-v1.3_Crunchy_Frog.tar.gz

# create a symlink directories for comfort mount volumes(short names)
RUN mkdir /bratdata && mkdir /bratcfg
# change directories owner to www-data and acess mode
RUN chown -R www-data:www-data /bratdata /bratcfg 
RUN chmod o-rwx /bratdata /bratcfg
# create a symlink directories 
RUN ln -s /bratdata /var/www/brat/brat-v1.3_Crunchy_Frog/data
RUN ln -s /bratcfg /var/www/brat/brat-v1.3_Crunchy_Frog/cfg 

# make that location a volume
VOLUME /bratdata
VOLUME /bratcfg

# add install_wrapper file and allow him to be execute
# wrapper run execute install.sh file with neceserry
# args - BRAT_USERNAME, BRAT_PASSWORD and BRAT_EMAIL
# we get them from environment variables in docker run command
ADD brat_install_wrapper.sh /usr/bin/brat_install_wrapper.sh
RUN chmod +x /usr/bin/brat_install_wrapper.sh

# change group for Apache2 acess and add default configuration
# file with virtual host parametres including port number (80)
RUN chown -R www-data:www-data /var/www/brat/brat-v1.3_Crunchy_Frog/
ADD 000-default.conf /etc/apache2/sites-available/000-default.conf

# Enable cgi (Apache2 can works with CGI scripts)
RUN a2enmod cgi
# Container listens 80 port
EXPOSE 80

# Using supervisor to monitor the apache process
# supervisor run bratconfig and apache2 
RUN mkdir -p /var/log/supervisor
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf 
CMD ["/usr/bin/supervisord"]
