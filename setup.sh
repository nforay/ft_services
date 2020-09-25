#/bin/bash
#in case of fire use: docker system prune -a

logdate() {
  while IFS= read -r line; do
    printf '%s %s\n' "[$(date +"%Y-%m-%d %T")]" "$line";
  done
}

#FT_SERVICES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )"
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
if ! command -v terminator &> /dev/null
then
  terminator -e "tail -f setup.log"
fi
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/main/manifests/namespace.yaml | logdate >> setup.log
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/main/manifests/metallb.yaml | logdate >> setup.log
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
#echo "dirname '$FT_SERVICES_DIR'"
#Store Minikube IP
#IP=$(kubectl get node -o=custom-columns='DATA:status.addresses[0].address' | sed -n 2p)
#kubectl create -f $FT_SERVICES_DIR/srcs/dashboard/recommended.yaml
#kubectl create serviceaccount dashboard-admin-sa
#kubectl create clusterrolebinding dashboard-admin-sa --clusterrole=cluster-admin --serviceaccount=default:dashboard-admin-sa
#echo "\e[31mMinikube IP:\t\e[39m$IP"
#echo "\e[31mDashboard:\t\e[39mhttp://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
#TOKEN="$(kubectl describe secret dashboard-admin-sa-token | grep token: | sed 's/token:\(\s*\)\(.*\)/\2/g')"
#echo "\e[31mToken:\t\t\e[39m$TOKEN"
#kubectl proxy
echo "🐳  [1/8] Docker: Building Nginx ..."
docker build -t img_nginx srcs/nginx | logdate >> setup.log
kubectl apply -k ./srcs/. | logdate >> setup.log
minikube dashboard
