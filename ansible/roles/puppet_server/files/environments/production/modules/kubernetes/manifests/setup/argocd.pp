# @summary Installs and configures ArgoCD
# @api private
class kubernetes::setup::argocd {
  exec { 'create-argocd-namespace':
    command     => 'kubectl create namespace argocd',
    path        => ['/usr/bin', '/bin'],
    unless      => 'kubectl get namespace argocd',
    require     => [Exec['create-join-command-fact'], Exec['deploy-flannel']],
    logoutput   => true,
  }

  exec { 'install-argocd':
    command     => 'kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml',
    path        => ['/usr/bin', '/bin'],
    require     => [Exec['create-join-command-fact'], Exec['create-argocd-namespace']],
    logoutput   => true,
  }

  exec { 'wait-for-argocd-pods':
    command     => 'kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s',
    path        => ['/usr/bin', '/bin'],
    require     => Exec['install-argocd'],
    logoutput   => true,
    timeout     => 360,
  }

  exec { 'get-argocd-admin-password':
    command     => 'kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d > /tmp/argocd_admin_password',
    path        => ['/usr/bin', '/bin'],
    require     => Exec['wait-for-argocd-pods'],
    creates     => '/root/.argocd_admin_password',
    logoutput   => true,
  }
}
