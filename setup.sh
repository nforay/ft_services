#/bin/bash
#in case of fire use: docker system prune -a
logdate() {
  while IFS= read -r line; do
    printf '%s %s\n' "[$(date +"%Y-%m-%d %T")]" "$line";
  done
}

#Check minikube version
minikube version | grep "minikube version: v1.13.1" >> /dev/null
if [ "$?" != 0 ];then
echo "\e[5m\e[33m[Error]\e[0m Minikube version mismatch. Please update using the following command:"
echo "curl -Lo minikube https://storage.googleapis.com/minikube/releases/v1.13.1/minikube-linux-amd64 &&\nchmod +x minikube &&\nsudo mkdir -p /usr/local/bin/ &&\nsudo install minikube /usr/local/bin/"
exit 1
fi

#Check if minikube is already running
minikube status >> /dev/null
if [ "$?" != 85 ];then
minikube delete
fi
echo "\e[33m[\e[32mft_services\e[33m] Starting Minikube, \e[5mthis may take a few minutes...\e[0m"

#Add user to docker group
echo $(whoami) | sudo -S usermod -aG docker $(whoami) > /dev/null

#Start Minikube
minikube start --vm-driver=docker
minikube addons enable metrics-server
minikube addons enable metallb
minikube addons enable dashboard
eval $(minikube docker-env)
echo "🌟  Deploying MetalLB ..."
echo "🌟  Begin setup log (tail -f setup.log)"
echo "🌟  Begin setup log" | logdate > setup.log
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/main/manifests/namespace.yaml | logdate >> setup.log
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/main/manifests/metallb.yaml | logdate >> setup.log
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

#Build docker images
echo "🐳  [1/7] Docker: Building Nginx ..."
docker build -t img_nginx srcs/nginx | logdate >> setup.log
echo "🐳  [2/7] Docker: Building FTPS ..."
docker build -t img_ftps srcs/ftps | logdate >> setup.log
echo "🐳  [3/7] Docker: Building Mysql ..."
docker build -t img_mysql srcs/mysql | logdate >> setup.log
echo "🐳  [4/7] Docker: Building Phpmyadmin ..."
docker build -t img_pma srcs/phpmyadmin | logdate >> setup.log
echo "🐳  [5/7] Docker: Building Wordpress ..."
docker build -t img_wp srcs/wordpress | logdate >> setup.log
echo "🐳  [6/7] Docker: Building InfluxDB ..."
docker build -t img_influxdb srcs/influxdb | logdate >> setup.log
echo "🐳  [7/7] Docker: Building Grafana ..."
docker build -t img_grafana srcs/grafana | logdate >> setup.log
kubectl apply -k ./srcs/. | logdate >> setup.log
echo "🌟  Starting Dashboard ..."
sleep 20;
echo "🌟  Service:\t\tLogin:\t\tPassword:"
echo "📚  FTPS:\t\tftps\t\tpassword"
echo "📚  Wordpress:\t\tadmin\t\tpassword"
echo "📚  Grafana:\t\tadmin\t\tadmin"
echo "📚  Phpmyadmin:\t\tadmin\t\tpassword"
echo "📚  InfluxDB:\t\tadmin\t\tpassword"
#Done
minikube dashboard
