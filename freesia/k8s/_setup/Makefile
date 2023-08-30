.PHONY: all

kube_version=1.28.0
####################################
# 初期設定まわり
####################################
install:
	apt update
	apt-mark unhold kubeadm kubelet kubectl
	apt -y install kubeadm=${kube_version}-00 kubectl=${kube_version}-00 kubelet=${kube_version}-00
	apt-mark hold kubeadm kubelet kubectl
init-kubeadm: copy-certs
	kubeadm init --config kubeadm.yaml
init-kubeconfig:
	rm -rf ${HOME}/.kube
	mkdir -p ${HOME}/.kube
	sudo cp -i /etc/kubernetes/admin.conf ${HOME}/.kube/config
	sudo chown $(id -u):$(id -g) ${HOME}/.kube/config
init-configuration:
	kubectl taint nodes --all node-role.kubernetes.io/control-plane- || :
	kubectl taint nodes --all node-role.kubernetes.io/master- || :
	kubectl apply -f rbac.yaml

init:	init-kubeadm init-kubeconfig init-configuration

####################################
# 証明書操作
####################################
generate-certs:
	cd certs && make ca.pem
	cd certs && make kubelet.pem

copy-certs: generate-certs
	mkdir -p /etc/kubernetes/pki
	cp certs/ca.pem /etc/kubernetes/pki/ca.crt
	cp certs/ca-key.pem /etc/kubernetes/pki/ca.key
	mkdir -p /var/lib/kubelet/pki
	cp certs/kubelet.pem /var/lib/kubelet/pki/kubelet.crt
	cp certs/kubelet-key.pem /var/lib/kubelet/pki/kubelet.key
	ls -lsa /var/lib/kubelet/pki

renew-certs: copy-certs
	kubeadm certs renew all --config kubeadm.yaml

####################################
# 動作確認、運用系
####################################
restart-service:
	systemctl stop kubelet
	systemctl stop docker
	systemctl start docker
	systemctl start kubelet

check-ca:
	openssl x509 -in certs/ca.pem -text -noout

reset:
	kubeadm reset -f

upgrade-plan: install
	kubeadm upgrade plan
upgrade:
	kubeadm upgrade apply v${kube_version}
