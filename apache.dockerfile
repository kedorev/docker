#Indique la source du repo
FROM httpd:latest

#Equivalent a www dans la vagrant / 
WORKDIR /usr/local/apache2/htdocs

#permet d'ouvrir le port
EXPOSE 80

#Script execution
# @TODO : add script
#RUN apt-get update && apt-get install -y git && rm index.html && git clone https://github.com/helfi92/studorlio.git .