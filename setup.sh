#/bin/bash
#in case of fire use: docker system prune -a

logdate() {
  while IFS= read -r line; do
    printf '%s %s\n' "[$(date +"%Y-%m-%d %T")]" "$line";
  done
}

#minikube status -> check return, delete si déja présent
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
echo "🌟  Begin setup log" | logdate > setup.log
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/main/manifests/namespace.yaml | logdate >> setup.log
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/main/manifests/metallb.yaml | logdate >> setup.log
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
#Store Minikube IP
#IP=$(kubectl get node -o=custom-columns='DATA:status.addresses[0].address' | sed -n 2p)
#echo "\e[31mMinikube IP:\t\e[39m$IP"
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
sleep 10;
minikube dashboard
