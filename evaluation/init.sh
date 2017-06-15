#!/bin/bash

tempPath="/tmp/"
tempName="tempInstallDocker"
tempPathGlobal=${tempPath}${tempName}
log="init.log"
passwordFile="tmpPassMySQLRoot"

echo "Les images seront créée avec pour nom par défaut 'mysql' pour l'instance mysql et 'apache' pour le httpd"
echo "Les images et conteneurs dépendant d'images avec ce nom seront suprimées."

while true; do
    read -p "Voulez-vous modifier les noms par defaut ? (y/n)" yn
    case $yn in
        [Yy]* )
			read -p "Saisir le nom du conteneur pour mysql : " mysqlName
    		read -p "Saisir le nom de l'image pour apache : " wordpressName
    		break;;
        [Nn]* ) 
			mysqlName="mysql"
			wordpressName="apache"
			break;;
        * ) echo "Please answer yes or no.";;
    esac
done

touch ${tempPathGlobal}
touch ${log}
touch ${passwordFile}

#Test if docker exist
which docker >> ${tempPathGlobal}

if [ $? -ne 0 ]
then
	exit -1
fi
docker --version | grep "Docker version" >> ${tempPathGlobal}
if [ $? -ne 0 ]
then
	exit -1
fi

#echo "conteneur stopped" >> ${log}
docker stop $(docker ps -a -q ) >> ${log}

#echo "conteneur closed" >> ${log}
docker rm $(docker ps -a -q ) >> ${log}
docker rmi $(docker ps -a -q ) >> ${log}

#Start 

echo "" >> ${log}
echo "-------------------SQL INSTALL------------" >> ${log}
echo "" >> ${log}

docker ps -a | grep ${mysqlName} >> ${tempPathGlobal}
if [ $? -eq 0 ]; then
	mysqlId="$(docker ps -aqf "name="${mysqlName})"
	docker stop ${mysqlId} >> ${log}
	docker rm ${mysqlId} >> ${log}
fi
docker images | grep ${mysqlName} >> ${tempPathGlobal}
if [ $? -eq 0 ]
then
	echo "skip remove mysql image" >> ${log}
	#docker rmi ${mysqlName} >> ${log}
fi

read -p "Saisir le mot de passe root : " rootPassword
echo "${rootPassword}" >> ${passwordFile}
echo "Root password = "${rootPassword} >> ${log}
echo "docker run --name ${mysqlName} -e MYSQL_ROOT_PASSWORD=${rootPassword} -d mysql" >> ${log}

docker run --name ${mysqlName} -e MYSQL_ROOT_PASSWORD=${rootPassword} -d mysql >> ${log}

mysqlId="$(docker ps -aqf "name="${mysqlName})"





echo "" >> ${log}
echo "------------------- Adminer ------------" >> ${log}
echo "" >> ${log}
adminerName="adminer_2"

docker ps -a | grep ${adminerName} >> ${tempPathGlobal}
if [ $? -eq 0 ]
then
	docker rm -f ${adminerName} >> ${log}
fi
#check if wordpress image allready present
docker images | grep ${adminerName} >> ${tempPathGlobal}
if [ $? -eq 0 ]
then
	docker rmi ${adminerName} >> ${log}
fi
echo "docker build -f adminer_df -t ${adminerName} . " >> ${log}
docker build -f adminer_df -t ${adminerName} . >> ${log}
echo "docker run --name ${adminerName} --link ${mysqlId} -p 4000:80 -d ${adminerName}" >> ${log}
docker run --name ${adminerName} --link ${mysqlId} -p 4001:80 -d ${adminerName} >> ${log}




echo "" >> ${log}
echo "------------------- Apache ------------" >> ${log}
echo "" >> ${log}

docker ps -a | grep ${wordpressName} >> ${tempPathGlobal}
if [ $? -eq 0 ]
then
	docker rm -f ${wordpressName} >> ${log}
fi
#check if wordpress image allready present
docker images | grep ${wordpressName} >> ${tempPathGlobal}
if [ $? -eq 0 ]
then
	docker rmi ${wordpressName} >> ${log}
fi
docker build -f apache_df -t ${wordpressName} . >> ${log}
echo "docker run --name ${wordpressName} --link ${mysqlId} -p 4000:80 -d ${wordpressName}" >> ${log}
docker run --name ${wordpressName} --link ${mysqlId} -p 4000:80 -d ${wordpressName} >> ${log}






echo "" >> ${log}
echo "------------------- rancher ------------" >> ${log}
echo "" >> ${log}
rancherName="rancher"

docker ps -a | grep ${rancherName} >> ${tempPathGlobal}
if [ $? -eq 0 ]
then
	docker rm -f ${rancherName} >> ${log}
fi
#check if wordpress image allready present
docker images | grep ${rancherName} >> ${tempPathGlobal}
if [ $? -eq 0 ]
then
	docker rmi ${rancherName} >> ${log}
fi
echo "docker build -f rancher_df -t ${rancherName} . " >> ${log}
docker build -f rancher_df -t ${rancherName} . >> ${log}
echo "docker run -d --name ${rancherName} --restart=unless-stopped -p 9090:8080 ${rancherName}" >> ${log}
docker run --name ${rancherName} --restart=unless-stopped -p 9090:8080 ${rancherName} >> ${log}


docker inspect ${rancherName} | grep '"IPAddress"' 
echo "Vous pouvez maintenant accéder au site avec l'adresse ip ci-dessus et le port 8080 ( exemple : 172.18.0.5:8080 )"
#docker run --rm --privileged -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/rancher:/var/lib/rancher rancher/agent:v1.2.2 http://172.18.0.3:8080/v1/scripts/2D1E2F85BAA2997C7ABF:1483142400000:adSxI3THSHCdBxnW5bhFY0aRm4

echo "" >> ${log}
echo "" >> ${log}
echo "\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"" >> ${log}
echo "\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"" >> ${log}
echo "\"\"\"\"\"\"\"\"\"\ End of creation \"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"" >> ${log}
echo "\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"" >> ${log}
echo "\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"" >> ${log}
echo "" >> ${log}

#rm -f ${tempInstallDocker}



#rm -f ${tempInstallDocker}