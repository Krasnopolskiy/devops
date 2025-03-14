KUBERNETES_VERSION=v1.32
CRIO_VERSION=v1.32

apt-get update
apt-get install -y software-properties-common curl

mkdir /etc/apt/keyrings/

curl -fsSL https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key |
    gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ /" |
    tee /etc/apt/sources.list.d/kubernetes.list

curl -fsSL https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/deb/Release.key |
    gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/deb/ /" |
    tee /etc/apt/sources.list.d/cri-o.list

apt-get update
apt-get install -y cri-o kubelet kubeadm kubectl

systemctl start crio.service

swapoff -a
modprobe br_netfilter
sysctl -w net.ipv4.ip_forward=1

kubeadm join 192.168.248.180:6443 --token q6geaw.dtkmemctrj02am7q --discovery-token-ca-cert-hash sha256:d05bff8cf2cafa0b29d347f18550cc1f417819a630513e95594481bd2b7fad76

kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
