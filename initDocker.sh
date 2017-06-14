#!/bin/bash

tempPath="/tmp/"
tempName="tempInstallDocker"
tempPathGlobal=${tempPath}${tempName}
log="installWordpress.log"
passwordFile="tmpPassMySQLRoot"

echo "Les images seront créée avec pour nom par défaut 'mysql' pour l'instance mysql et 'wordpress' pour le httpd"
echo "Les images et conteneurs dépendant d'images avec ce nom seront suprimées."

while true; do
    read -p "Voulez-vous modifier les noms par defaut ? (y/n)" yn
    case $yn in
        [Yy]* )
			read -p "Saisir le nom du conteneur pour mysql : " mysqlName
    		read -p "Saisir le nom de l'image pour wordpress : " wordpressName
    		break;;
        [Nn]* ) 
			mysqlName="mysql"
			wordpressName="wordpress"
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
	echo "skip"
	#docker rmi ${mysqlName} >> ${log}
fi

read -p "Saisir le mot de passe root : " rootPassword
echo "${rootPassword}" >> ${passwordFile}
echo "Root password = "${rootPassword} >> ${log}
echo "docker run --name ${mysqlName} -e MYSQL_ROOT_PASSWORD=${rootPassword} -d mysql" >> ${log}

docker run --name ${mysqlName} -e MYSQL_ROOT_PASSWORD=${rootPassword} -d mysql >> ${log}

mysqlId="$(docker ps -aqf "name="${mysqlName})"





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

wordpressId="$(docker ps -aqf "name="${wordpressName})"

#sudo docker exec -it ${wordpressId} ${PWD}/install_wp.sh bash

echo "\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"" >> ${log}
echo "\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"" >> ${log}
echo "\"\"\"\"\"\"\"\"\"\ End of creation \"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"" >> ${log}
echo "\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"" >> ${log}
echo "\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"" >> ${log}
echo "" >> ${log}

#rm -f ${tempInstallDocker}