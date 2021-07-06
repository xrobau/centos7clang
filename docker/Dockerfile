FROM centos:7
ARG SRCFILE
ARG CLANGVERS
ADD ${SRCFILE} /usr/local
COPY build.repo /etc/yum.repos.d/
RUN yum -y update
RUN yum -y groupinstall 'Development Tools'
RUN yum -y install automake autoconf libtool epel-release libjwt-devel libcurl-devel devtoolset-10
RUN yum -y install openssl11-devel openssl11-libs cmake3 ccache

# Upper AND lowercase.
ENV openssl_CFLAGS=-I/usr/include/openssl11
ENV OPENSSL_CFLAGS=-I/usr/include/openssl11
ENV openssl_LIBS=-L/usr/lib64/openssl11\ -lssl\ -lcrypto
ENV OPENSSL_LIBS=-L/usr/lib64/openssl11\ -lssl\ -lcrypto

# Remove swig2, swig3 is the new hotness.
RUN yum -y remove swig

# Note that lua doesn't work, as it's not new enough. It's still there anyway. Python36-sphinx needs
# its executable names changed, or linked, or whatever, OR discover the way to tell cmake to use the
# new filenames?
RUN yum -y install libedit-devel libxml2-devel python36-pygment python36-PyYAML swig3 doxygen python36-sphinx lua lua-devel python36-devel

# This is exactly the same as running /opt/rh/devtoolset-10/enable, but it's there forever!
ENV PATH=/usr/lib64/ccache:/opt/rh/devtoolset-10/root/usr/bin:/usr/lib64/ccache:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LD_LIBRARY_PATH=/opt/rh/devtoolset-10/root/usr/lib64:/opt/rh/devtoolset-10/root/usr/lib:/opt/rh/devtoolset-10/root/usr/lib64/dyninst:/opt/rh/devtoolset-10/root/usr/lib/dyninst:/opt/rh/devtoolset-10/root/usr/lib64:/opt/rh/devtoolset-10/root/usr/lib
ENV PKG_CONFIG_PATH=/opt/rh/devtoolset-10/root/usr/lib64/pkgconfig
ENV CCACHE_DIR=/usr/local/ccache
ENV CCACHE_PATH=/opt/rh/devtoolset-10/root/bin

WORKDIR /usr/local/llvm-project-llvmorg-${CLANGVERS}/build

