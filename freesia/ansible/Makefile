.PHONY: all

# ansible-setup:
# 	pip3 install -u ansible
# 	ansible-galaxy collection install community.general

poetry:
	pip install -U pip
	pip install -U poetry
deploy:
	poetry run ansible-playbook -i inventory/hosts.yaml site.yaml
