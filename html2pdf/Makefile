REPO ?= github.com/7oaksgroup/html2pdf
TAG ?= $(shell git rev-parse HEAD)-dev
BUILD_DATE := $(shell date +%FT%T%z)

all: linux osx compress

linux:
			GOOS=linux GOARCH=amd64 $(MAKE) build

osx:
			GOOS=darwin GOARCH=amd64 $(MAKE) build

build: 	bin
				$(eval SUFFIX=_$(GOOS)_$(GOARCH))
				go build -ldflags "-s" -o ./bin/html2pdf$(SUFFIX) ./cmd/html2pdf

# compress all lanes binaries
compress: bin get-upx
					@$(UPX) ./bin/html2pdf*

bin:
				@mkdir -p ./bin/


UPX := $(shell which upx)
upx_version := 3.96

# fetch a local copy of upx for binary compression (only if it's not already installed)
#TODO: update based on arch
get-upx:
ifeq ($(UPX),)
	@mkdir -p ./upx/
	@curl -Ls https://github.com/upx/upx/releases/download/v$(upx_version)/upx-$(upx_version)-amd64_linux.tar.xz | tar Jx -C ./upx/ --strip-components 1
	$(eval UPX := ./upx/upx)
endif
	@$(UPX) --version
