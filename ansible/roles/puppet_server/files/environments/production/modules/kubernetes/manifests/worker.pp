class kubernetes::worker {
  notify { 'kubernetes-worker-ready':
    message => "sudo kubeadm join 10.0.10.3:6443 --token abc123... --discovery-token-ca-cert-hash sha256:def456...\n"
  }
}
