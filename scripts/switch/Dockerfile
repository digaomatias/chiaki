# use full qualified container uri (for security reason)
# do not assume that docker.io is the default registry 
# from all systems / distrib
FROM docker.io/devkitpro/devkita64_devkitarm

# Devkitpro's do not support use of pacman from CI (github)
# https://devkitpro.org/viewtopic.php?f=15&t=9103#p16883
# they recommand to use docker images 
# for this purpose at https://hub.docker.com/u/devkitpro

ENV WORKDIR="/build"
WORKDIR "${WORKDIR}"

# And install chiaki CI switch requirements
RUN apt-get update \
  && apt-get install -y \
    python3-pip \
    protobuf-compiler \
  && rm -r /var/cache/apt

RUN pip3 install protobuf

VOLUME ${WORKDIR}
# nxlink server port
EXPOSE 28771
ENTRYPOINT ["/bin/bash"]
