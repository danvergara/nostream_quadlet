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

.PHONY: help
## help: Prints this help message
help:
	@echo "Usage:"
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'
