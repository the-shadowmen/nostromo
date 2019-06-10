# Prow Jobs

## Core Components

- `hook` is the most important piece. It is a stateless server that listens for GitHub webhooks and dispatches them to the appropriate plugins. Hook's plugins are used to trigger jobs, implement 'slash' commands, post to Slack, and more. See the [`prow/plugins`](/prow/plugins/) directory for more information on plugins.
- `plank` is the controller that manages the job execution and lifecycle for jobs that run in k8s pods.
- `deck` presents a nice view of [recent jobs](https://prow.k8s.io/), [command](https://prow.k8s.io/command-help) and [plugin](https://prow.k8s.io/plugins) help information, the [current status](https://prow.k8s.io/tide) and (history)[https://prow.k8s.io/tide-history] of merge automation, and a [dashboard for PR authors](https://prow.k8s.io/pr).
- `horologium` triggers periodic jobs when necessary.
- `sinker` cleans up old jobs and pods.<Paste>
- `tide` manages retesting and merging PRs once they meet the configured merge criteria. See [its README](./tide/README.md) for more information.

Reference: https://raw.githubusercontent.com/kubernetes/test-infra/master/prow/cmd/README.md

- **Following**: https://github.com/kubernetes/test-infra/blob/master/prow/getting_started_deploy.md

- [Configure Gcloud Storage](https://github.com/kubernetes/test-infra/blob/master/prow/getting_started_deploy.md#configure-cloud-storage)
```
mkdir ~/downloads
wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-231.0.0-linux-x86_64.tar.gz -O google-cloud-sdk-231.0.0-linux-x86_64.tar.gz
cd downloads && tar xvzf google-cloud-sdk-231.0.0-linux-x86_64.tar.gz
cd google-cloud-sdk && ./install.sh

## Configure new SA for Prow
gcloud beta iam service-accounts create sa-comm-prow --description "SA for Prow Purposes on Communitty dept" --display-name "SA-Prow"

## Create the Bucket
## Expose it
## Grant write access to allow Prow to upload the content

## Serialize the new SA using a new key
gcloud iam service-accounts keys create ~/private/sa-comm-prow.json --iam-account sa-comm-prow@cnvlab-209908.iam.gserviceaccount.com

## Create Secret file with the SA json file
kubectl create secret generic gcs-credentials --from-file=sa-comm-prow.json

## Check prow config and Submit
## Use the nostromo repository to find the config.yaml and plugins.yaml files
run --verbose_failures //prow/cmd/checkconfig -- \
    --plugin-config=/home/jparrill/ownCloud/RedHat/RedHat_Engineering/kubevirt/CI-CD/Prow/repos/nostromo/plugins.yaml \
    --config-path=/home/jparrill/ownCloud/RedHat/RedHat_Engineering/kubevirt/CI-CD/Prow/repos/nostromo/config.yaml


```


## Tide

Works as a separated component of Prow and needs some things to make them done before use it.

### Pre-reqs for Tide

- [You need to register a GH OAUTH app which will monitor the PRs statuses](https://github.com/kubernetes/test-infra/blob/master/prow/docs/pr_status_setup.md)


## References

- https://github.com/kubernetes/test-infra/blob/master/prow/cmd/tide/maintainers.md#best-practices
