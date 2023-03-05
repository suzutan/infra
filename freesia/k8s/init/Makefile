.PHONY: all

apply:
	kustomize build --enable-helm . | kubectl apply -f-
