# Prow and Quickstart

Prow is a Kubernetes based CI/CD system. Jobs can be triggered by various types of events and report their status to many different services. In addition to job execution, Prow provides GitHub automation in the form of policy enforcement, chat-ops via /foo style commands, and automatic PR merging.

**NOTE|WARNING**: In order to make Prow work fine with your repo, the Kubernetes cluster **MUST** be reachable by GitHub Webhook. 

## Articles to read and understand

### Introduction

- Readme file: https://github.com/kubernetes/test-infra/blob/master/prow/README.md
- Command Help: https://prow.k8s.io/command-help
- Prow Go Doc: https://godoc.org/k8s.io/test-infra/prow
- Mandatory Article to read: https://kurtmadel.com/posts/native-kubernetes-continuous-delivery/prow/
- Prow Quickstart: https://github.com/kubernetes/test-infra/blob/master/prow/getting_started_deploy.md
- Prow Images: https://github.com/kubernetes/test-infra/blob/master/prow/cmd/README.md#core-components
- Prow PR Workflow: https://raw.githubusercontent.com/kubernetes/test-infra/master/prow/docs/pr-interactions-sequence.svg?sanitize=true

### Prow Plugins

- Prow Plugins: https://prow.k8s.io/plugins
- Prow Code-Review process: https://github.com/kubernetes/community/blob/master/contributors/guide/owners.md#the-code-review-process

### Prow Jobs

- Prow Jobs overview: https://kurtmadel.com/posts/native-kubernetes-continuous-delivery/prow/#prow-is-a-ci-cd-job-executor
- Life of a Prow Job: https://github.com/kubernetes/test-infra/blob/master/prow/life_of_a_prow_job.md
    - Webhook Payload sample: https://github.com/kubernetes/test-infra/tree/c8829eef589a044126289cb5b4dc8e85db3ea22f/prow/cmd/phony/examples
- Prow Jobs Deep Dive:
    - https://github.com/kubernetes/test-infra/blob/master/prow/jobs.md
    - https://github.com/kubernetes/test-infra/tree/master/prow/cmd/phaino
    - https://github.com/kubernetes/test-infra/blob/master/prow/cmd/tide/config.md

### Others

- Another useful Article: https://kurtmadel.com/posts/native-kubernetes-continuous-delivery/native-k8s-cd/
- Kubevirt Project-Infra: https://github.com/kubevirt/project-infra
- NGINX Ingress Controller:
	- https://github.com/kubernetes/ingress-nginx
	- https://github.com/kubernetes/ingress-nginx/blob/master/docs/deploy/index.md
	- https://github.com/kubernetes/ingress-nginx/tree/master/docs/examples

## Hands on

- Following **https://github.com/kubernetes/test-infra/blob/master/prow/getting_started_deploy.md**
- Deploy instance on libvirt with terraform:
```
cd ~cnv/repos/kubevirt-tutorial/administrator/terraform/libvirt
terraform init -get -upgrade=true
terraform apply -var-file varfiles/jparrill.tf -refresh=true -auto-approve
```

- Install [Golang](https://linux4one.com/how-to-install-go-on-centos-7/), [Bazel](https://docs.bazel.build/versions/master/install-redhat.html) and Tackel on guest
```
cd ~ && curl -O https://dl.google.com/go/go1.11.5.linux-amd64.tar.gz
sha256sum go1.11.5.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.11.5.linux-amd64.tar.gz
sudo vi ~/.bash_profile ## add those lines:
# export GOPATH=$HOME/go
# export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
mkdir ~/go
source ~/.bash_profile
## Jobs by Bazel will need GCC
sudo yum groupinstall "development tools" -y
sudo yum install wget -y
sudo wget https://copr.fedorainfracloud.org/coprs/vbatts/bazel/repo/epel-7/vbatts-bazel-epel-7.repo -O /etc/yum.repos.d/bazel.repo
sudo yum install bazel -y
go get -u k8s.io/test-infra/prow/cmd/tackle
```

- Create cluster elements to work with GitHub
```
kubectl create clusterrolebinding cluster-admin-binding-kubernetes-admin --clusterrole=cluster-admin --user=kubernetes-admin
mkdir ~/private
openssl rand -hex 20 > $HOME/private/HMAC_TOKEN
kubectl create secret generic hmac-token --from-file=hmac=$HOME/private/HMAC_TOKEN
echo "f25cc009637532179fb2cdec2d888a39749ac067" > $HOME/private/OAUTH_SECRET
kubectl create secret generic oauth-token --from-file=oauth=$HOME/private/OAUTH_SECRET
```

- Spin up Prow
```
cd $HOME && git clone https://github.com/kubernetes/test-infra.git && cd $HOME/test-infra
kubectl create namespace prow
kubectl config set-context $(kubectl config current-context) --namespace=prow
kubectl apply -f prow/cluster/starter.yaml
# Use sshuttle to access the Prow interface
sshuttle -r jparrill@192.168.1.XXX 192.168.123.0/24 -v
```

- Then access to the NodePort using your Kubeadmin node:
```
[kubevirt@k8s-kubemaster test-infra]$ kubectl get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
deck         NodePort    10.102.35.212   <none>        80:32494/TCP     2d21h
hook         NodePort    10.101.54.234   <none>        8888:31050/TCP   2d21h
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP          3d15h
tide         NodePort    10.100.34.208   <none>        80:31840/TCP     2d21h

http://192.168.123.234:32494/
```

- Add WebHook to Github
```
# We need to update git in order to let Bazel to use "git -C ...." sentences
sudo sh -c "cat <<EOF > /etc/yum.repos.d/wandisco-git.repo
[wandisco-git]
name=Wandisco GIT Repository
baseurl=http://opensource.wandisco.com/centos/7/git/\$basearch/
enabled=1
gpgcheck=1
gpgkey=http://opensource.wandisco.com/RPM-GPG-KEY-WANdisco
EOF"
sudo rpm --import http://opensource.wandisco.com/RPM-GPG-KEY-WANdisco
sudo yum update git -y
####

go get -u k8s.io/test-infra/experiment/add-hook
bazel run //experiment/add-hook -- \
  --hmac-path=$HOME/private/HMAC_TOKEN \
  --github-token-path=$HOME/private/OAUTH_SECRET \
  --hook-url http://kubevirt-prow-0.gce.sexylinux.net:30300/hook \
  --repo the-shadowmen \
  --confirm=false
```

- Add Config and Plugins to Prow
```
mkdir $HOME/prow_conf
cat <<EOF > $HOME/prow_conf/plugins.yaml \
plugins:
    the-shadowmen/nostromo:
        - size
        - label
        - hold
        - assign
        - blunderbuss
        - lifecycle
        - verify-owners
        - wip
EOF

cat <<EOF > $HOME/prow_conf/config.yaml \
prowjob_namespace: default
pod_namespace: test-pods
EOF

cd $HOME/test-infra
bazel run //prow/cmd/checkconfig -- --plugin-config=$HOME/prow_conf/plugins.yaml --config-path=$HOME/prow_conf/config.yaml
kubectl create configmap plugins \
  --from-file=$HOME/prow_conf/plugins.yaml --dry-run -o yaml \
  | kubectl replace configmap plugins -f -

cd $HOME/prow_conf && kubectl create configmap config --from-file=config.yaml=config.yaml --dry-run -o yaml | kubectl replace configmap config -f -
cd $HOME/prow_conf && kubectl create configmap plugins --from-file=$HOME/prow_conf/plugins.yaml --dry-run -o yaml | kubectl replace configmap plugins -f -
```


- Labels
```
cat <<EOF > $HOME/prow_conf/labels.yaml \
---
default:
  labels:
    - color: e11d21
      description: Indicates that a PR should not merge because someone has issued a /hold command.
      name: do-not-merge/hold
      target: prs
      prowPlugin: hold
      addedBy: anyone          
    - name: kind/blocker
      color: b60205
      target: both
      addedBy: anyone
      prowPlugin: label
    - name: kind/bug
      color: ee0701
      target: both
      addedBy: anyone
      prowPlugin: label
    - name: kind/enhancement
      color: bfd4f2
      target: both
      addedBy: anyone
      prowPlugin: label
    - name: kind/proposal
      color: bfd4f2
      target: both
      addedBy: anyone
      prowPlugin: label
    - name: kind/question
      color: cc317c
      target: both
      addedBy: anyone
      prowPlugin: label
    - name: kind/tracker
      color: bc19c1
      target: both
      addedBy: anyone
      prowPlugin: label
    - color: e11d21
      description: Categorizes issue or PR as related to adding, removing, or otherwise changing an API
      name: kind/api-change
      target: both
      prowPlugin: label
      addedBy: anyone
    - name: size/L
      color: ee9900
      target: both
      previously:
        - name: size-L
          color: f9d0c4
      addedBy: prow
      prowPlugin: size
    - name: size/M
      color: eebb00
      target: both
      previously:
        - name: size-M
          color: f9d0c4
      addedBy: prow
      prowPlugin: size
    - name: size/S
      color: 77bb00
      target: both
      previously:
        - name: size-S
          color: f9d0c4
      addedBy: prow
      prowPlugin: size
    - name: size/XL
      color: ee5500
      target: both
      previously:
        - name: size-XL
          color: f9d0c4
      addedBy: prow
      prowPlugin: size
    - color: "009900"
      name: size/XS
      target: both
      addedBy: prow
      prowPlugin: size
    - color: ee0000
      name: size/XXL
      target: both
      addedBy: prow
      prowPlugin: size
    - color: d3e2f0
      description: Indicates that an issue or PR should not be auto-closed due to staleness.
      name: lifecycle/frozen
      target: both
      prowPlugin: lifecycle
      addedBy: prow
    - color: 8fc951
      description: Indicates that an issue or PR is actively being worked on by a contributor.
      name: lifecycle/active
      target: both
      prowPlugin: lifecycle
      addedBy: prow
    - color: "604460"
      description: Denotes an issue or PR that has aged beyond stale and will be auto-closed.
      name: lifecycle/rotten
      target: both
      prowPlugin: lifecycle
      addedBy: prow
    - color: "795548"
      description: Denotes an issue or PR has remained open with no activity and has become stale.
      name: lifecycle/stale
      target: both
      prowPlugin: lifecycle
      addedBy: prow

kubectl create configmap label-config --from-file=$HOME/prow_conf/labels.yaml -o yaml
```
