# Prow Jobs


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
gcloud iam service-accounts keys create ~/private/service-account.json --iam-account sa-comm-prow@cnvlab-209908.iam.gserviceaccount.com

## Create Secret file with the SA json file
kubectl create secret generic gcs --from-file=service-account.json

## Check prow config and Submit
## Use the nostromo repository to find the config.yaml and plugins.yaml files
run --verbose_failures //prow/cmd/checkconfig -- \
    --plugin-config=/home/jparrill/ownCloud/RedHat/RedHat_Engineering/kubevirt/CI-CD/Prow/repos/nostromo/plugins.yaml \
    --config-path=/home/jparrill/ownCloud/RedHat/RedHat_Engineering/kubevirt/CI-CD/Prow/repos/nostromo/config.yaml

# Use make u

```


## Tide

Works as a separated component of Prow and needs some things to make them done before use it.

### Pre-reqs for Tide

- [You need to register a GH OAUTH app which will monitor the PRs statuses](https://github.com/kubernetes/test-infra/blob/master/prow/docs/pr_status_setup.md)


## References

- https://github.com/kubernetes/test-infra/blob/master/prow/cmd/tide/maintainers.md#best-practices
