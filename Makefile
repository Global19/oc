all: build
.PHONY: all

GO_LD_EXTRAFLAGS :=-X github.com/openshift/oc/vendor/k8s.io/kubernetes/pkg/version.gitMajor="1" \
                   -X github.com/openshift/oc/vendor/k8s.io/kubernetes/pkg/version.gitMinor="14" \
                   -X github.com/openshift/oc/vendor/k8s.io/kubernetes/pkg/version.gitVersion="v1.14.0+724e12f93f" \
                   -X github.com/openshift/oc/vendor/k8s.io/kubernetes/pkg/version.gitCommit="$(shell git rev-parse --short "HEAD^{commit}" 2>/dev/null)" \
                   -X github.com/openshift/oc/vendor/k8s.io/kubernetes/pkg/version.buildDate="$(shell date -u +'%Y-%m-%dT%H:%M:%SZ')" \
                   -X github.com/openshift/oc/vendor/k8s.io/kubernetes/pkg/version.gitTreeState="clean"


# Include the library makefile
include $(addprefix ./vendor/github.com/openshift/library-go/alpha-build-machinery/make/, \
	golang.mk \
	targets/openshift/deps.mk \
	targets/openshift/images.mk \
)

GO_BUILD_PACKAGES :=$(strip \
	./cmd/... \
)
# These tags make sure we can statically link and avoid shared dependencies
GO_BUILD_FLAGS :=-tags 'include_gcs include_oss containers_image_openpgp no_openssl gssapi'

# This will call a macro called "build-image" which will generate image specific targets based on the parameters:
# $0 - macro name
# $1 - target suffix
# $2 - Dockerfile path
# $3 - context directory for image build
$(call build-image,ose-cli,./images/cli/Dockerfile.rhel,.)

$(call build-image,ose-deployer,./images/deployer/Dockerfile.rhel,.)
image-ose-deployer: image-ose-cli

$(call build-image,ose-recycler,./images/recycler/Dockerfile.rhel,.)
image-ose-recycler: image-ose-cli

