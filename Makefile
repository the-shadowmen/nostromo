.PHONY: update-config update-plugins update-labels

update-config:
	kubectl create configmap config --from-file=config.yaml=config.yaml --dry-run -o yaml | kubectl replace configmap config -f -

update-plugins:
	kubectl create configmap plugins --from-file=plugins.yaml=plugins.yaml --dry-run -o yaml | kubectl replace configmap plugins -f -

update-labels:
	kubectl create configmap label-config --from-file=labels.yaml=labels.yaml --dry-run -o yaml | kubectl replace configmap plugins -f -
