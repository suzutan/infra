.PHONY: kubelet.pem

ca.pem:
	cfssl gencert -initca ca-csr.json | cfssljson -bare ca

kubelet.pem:
	cfssl gencert -ca ca.pem -ca-key ca-key.pem -config config.json -profile kubelet kubelet.json | cfssljson -bare kubelet -

clean:
	rm -rf *.pem
	rm -rf *.csr
