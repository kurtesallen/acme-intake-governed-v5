.PHONY: test
test:
    opa test policy -v

.PHONY: fmt
fmt:
    opa fmt -w policy

.PHONY: build
build:
    opa build -b -o bundle.tar.gz policy
