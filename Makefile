SECRET := $$(openssl rand -hex 128)

.PHONY: quadlet-dry-run
## rm-systemd: Run quadlet executable in dry-run mode 
quadlet-dry-run:
	/usr/libexec/podman/quadlet --dryrun --user

.PHONY: rm-systemd
## rm-systemd: Delete all the content in the systemd dir
rm-systemd:
	rm $(HOME)/.config/containers/systemd/*

.PHONY: cp-systemd-paid
## cp-systemd-paid: copy all the content of local systemd dir to the systemd dir for paid relay
cp-systemd-paid:
	cp systemd/* $(HOME)/.config/containers/systemd
	rm $(HOME)/.config/containers/systemd/nostream-public-configmap.yml

.PHONY: cp-systemd-public
## cp-systemd-public: copy all the content of local systemd dir to the systemd dir for public relay
cp-systemd-public:
	cp systemd/* $(HOME)/.config/containers/systemd
	rm $(HOME)/.config/containers/systemd/nostream-configmap.yml

.PHONY: cp-nginx-conf
cp-nginx-conf:
## cp-nginx-conf: copy the nginx config for paid relay
	cp nostream_quadlet.conf /etc/nginx/conf.d/nostream-quadlet.conf

.PHONY: cp-nginx-public-conf
cp-nginx-public-conf:
## cp-nginx-public-conf: copy the nginx config for paid relay
	cp nostream_quadlet_public.conf /etc/nginx/conf.d/nostream-quadlet.conf

.PHONY: reload
## reload: Reload systemd 
reload:
	systemctl --user daemon-reload

.PHONY: start
## start: start the services
start:
	systemctl --user start nostream-pod.service

.PHONY: secret
## secret: Creates a secret
secret:
	@echo $(SECRET)

.PHONY: secrets
## secrets: Creates a podman secrets
secrets: nostream-secret postgres-password redis-password nodeless-api-key-secret nodeless-webhook-secret
	@echo "generating secrets"


.PHONY: public-relay-secrets
## public-relay-secrets: Creates a podman secrets
public-relay-secrets: nostream-secret postgres-password redis-password
	@echo "generating public relay secrets"

.PHONY: nostream-secret
## Generate a secret with: openssl rand -hex 128
nostream-secret:
	kubectl create secret generic \
    --from-literal=password="${SECRET}" \
   nostream-secret-kube \
    --dry-run=client \
    -o yaml | \
    podman kube play - && \
	echo -n "${SECRET}" | \
    podman secret create nostream-secret-container -

.PHONY: postgres-password
## Generate a K8s secret for the Postgres Password
postgres-password:
	kubectl create secret generic \
    --from-literal=password="${NOSTREAM_DB_PASSWORD}" \
    nostream-db-password-kube \
    --dry-run=client \
    -o yaml | \
    podman kube play - && \
	echo -n "${NOSTREAM_DB_PASSWORD}" | \
    podman secret create nostream-db-password-container -

.PHONY: redis-password
## Generate a K8s secret for the Redis Password
redis-password:
	kubectl create secret generic \
    --from-literal=password="${NOSTREAM_CACHE_PASSWORD}" \
    nostream-cache-password-kube \
    --dry-run=client \
    -o yaml | \
    podman kube play - && \
	echo -n "${NOSTREAM_CACHE_PASSWORD}" | \
    podman secret create nostream-cache-password-container -

.PHONY: nodeless-api-key-secret
## Generate a K8s secret for the Nodeless API Key
nodeless-api-key-secret:
	kubectl create secret generic \
    --from-literal=password="${NODELESS_API_KEY}" \
    nostream-nodeless-api-key-kube \
    --dry-run=client \
    -o yaml | \
    podman kube play - && \
	echo -n "${NODELESS_API_KEY}" | \
    podman secret create nostream-nodeless-api-key-container -

.PHONY: nodeless-webhook-secret
## Generate a K8s secret for the Nodeless WebHook Secret
nodeless-webhook-secret:
	kubectl create secret generic \
    --from-literal=password="${NODELESS_WEBHOOK_SECRET}" \
    nostream-nodeless-webhook-secret-kube \
    --dry-run=client \
    -o yaml | \
    podman kube play - && \
	echo -n "${NODELESS_WEBHOOK_SECRET}" | \
    podman secret create nostream-nodeless-webhook-secret-container -

.PHONY: help
## help: Prints this help message
help:
	@echo "Usage:"
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'
