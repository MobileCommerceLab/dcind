FROM docker:18.03-dind
MAINTAINER pstory@andrew.cmu.edu

ENV DOCKER_COMPOSE_VERSION=1.20.1 \
    ENTRYKIT_VERSION=0.4.0

# Install Docker and Docker Compose
RUN apk --update --no-cache add \
    bash \
    coreutils \
    curl \
    device-mapper \
    iptables \
    make \
    py-pip \
    redis \
 && apk upgrade \
 && pip install docker-compose==${DOCKER_COMPOSE_VERSION} \
# Install entrykit
 && curl -L https://github.com/progrium/entrykit/releases/download/v${ENTRYKIT_VERSION}/entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz | tar zx \
 && chmod +x entrykit \
 && mv entrykit /bin/entrykit \
 && entrykit --symlink \
# Install Bash, Git, and Git LFS
 && apk add --no-cache bash git openssl \
 && wget -qO- https://github.com/git-lfs/git-lfs/releases/download/v2.1.1/git-lfs-linux-amd64-2.1.1.tar.gz | tar xz \
 && mv git-lfs-*/git-lfs /usr/bin/ \
 && rm -rf git-lfs-* \
 && git lfs install \
# cleanup
 && rm -rf /var/cache/apk/* \
 && rm -rf /root/.cache


# Include useful functions to start/stop docker daemon in garden-runc containers in Concourse CI.
# Example: source /docker-lib.sh && start_docker
COPY docker-lib.sh /docker-lib.sh

ENTRYPOINT [ \
	"switch", \
		"shell=/bin/sh", "--", \
	"codep", \
		"/usr/local/bin/dockerd" \
]
