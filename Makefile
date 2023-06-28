SECRET := $$(openssl rand -hex 128)

.PHONY: quadlet-dry-run
## rm-systemd: Run quadlet executable in dry-run mode 
quadlet-dry-run:
	/usr/libexec/podman/quadlet -dryrun -user

.PHONY: rm-systemd
## rm-systemd: Delete all the content in the systemd dir
rm-systemd:
	rm $(HOME)/.config/containers/systemd/*

.PHONY: cp-systemd
## cp-systemd: Copy all the content of local systemd dir to the systemd dir
cp-systemd:
	cp systemd/* $(HOME)/.config/containers/systemd 

.PHONY: reload
## reload: Reload systemd 
reload:
	systemctl --user daemon-reload

.PHONY: start
## start: start the services
start:
	systemctl --user start nostream-pod.service

.PHONY: nostream-secret
## Generate a secret with: openssl rand -hex 128
nostream-secret:
	kubectl create secret generic \
    --from-literal=password="${SECRET}" \
   nostrean-secret-kube \
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

.PHONY: help
## help: Prints this help message
help:
	@echo "Usage:"
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'
