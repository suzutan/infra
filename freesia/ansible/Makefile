.PHONY: all

ansible-setup:
	pip3 install -u ansible
	ansible-galaxy collection install community.general

deploy:
	ansible-playbook -i inventory/hosts.yaml site.yaml
