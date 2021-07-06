VERSION=12.0.0
DOCKERTAG=$(shell pwd)/.docker_build
OUTPUT=$(shell pwd)/clang$(VERSION)
FILENAME=llvmorg-$(VERSION).tar.gz
SOURCEURL=https://github.com/llvm/llvm-project/archive/refs/tags/$(FILENAME)
DESTFILE=$(shell pwd)/docker/$(FILENAME)
NPROCS=$(shell nproc)
JOBS=$(shell echo $$(( $(NPROCS) * 2 )) )
BUILDDIR=$(shell pwd)/build
TARBALL=clang+llvm-$(VERSION)-x86_64-linux-gnu-centos7.tar.xz
VOLUMES=-v /usr/local/ccache:/usr/local/ccache -v $(OUTPUT):/usr/local/clang$(VERSION) -v $(BUILDDIR):/usr/local/llvm-project-llvmorg-$(VERSION)/build

.PHONY: shell all compile install package

shell: all
	docker run --rm $(VOLUMES) -it clangbuilder:$(VERSION) bash

package: $(TARBALL)

$(TARBALL): $(OUTPUT)/bin/clang
	tar cfvJ $(@) clang$(VERSION)

$(OUTPUT)/bin/clang: $(BUILDDIR)/bin/clang
	docker run --rm $(VOLUMES) -it clangbuilder:$(VERSION) make -j$(JOBS) install
	touch $(@)

$(BUILDDIR)/bin/clang: $(BUILDDIR)/Makefile
	docker run --rm $(VOLUMES) -it clangbuilder:$(VERSION) make -j$(JOBS)
	touch $(@)

all: /usr/local/ccache/ccache.conf $(DESTFILE) $(OUTPUT) $(BUILDDIR) $(DOCKERTAG)

$(BUILDDIR)/Makefile: $(DOCKERTAG)
	echo makefile && exit 1
	docker run --rm $(VOLUMES) -it clangbuilder:$(VERSION) cmake3 -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;libcxx;libcxxabi;libunwind;lldb;compiler-rt;lld;polly" -DCMAKE_INSTALL_PREFIX=/usr/local/clang$(VERSION) -DCMAKE_BUILD_TYPE=Release -G "Unix Makefiles" ../llvm

# We have all files in the docker subdir as a requirement so we rebuild if stuff
# changes there.
$(DOCKERTAG): $(wildcard docker/*)
	docker build --build-arg SRCFILE=$(FILENAME) --build-arg CLANGVERS=$(VERSION) -t clangbuilder:$(VERSION) docker && touch $(@)

$(OUTPUT) $(BUILDDIR):
	mkdir -p $(@); chmod 0777 $(@)

/usr/local/ccache/ccache.conf: ccache.conf
	mkdir -p $(@D) && chmod 777 $(@D)
	cp $(<) $(@)

$(DESTFILE):
	wget -O $(@) $(SOURCEURL)
