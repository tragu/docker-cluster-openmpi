# Build this image:  docker build -t mpi .
#

FROM ubuntu:18.04
# FROM phusion/baseimage

MAINTAINER rahul <tankasalarahulgupta@gmail.com>

ENV USER mpirun

ENV DEBIAN_FRONTEND=noninteractive \
    HOME=/home/${USER} 


RUN apt-get update -y && \
    apt-get install -y --no-install-recommends sudo apt-utils && \
    apt-get install -y --no-install-recommends openssh-server \
    gcc gfortran libopenmpi-dev openmpi-bin openmpi-common openmpi-doc binutils && \
    apt-get clean && apt-get purge && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /var/run/sshd
RUN echo 'root:${USER}' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# ------------------------------------------------------------
# Add an 'mpirun' user
# ------------------------------------------------------------

RUN adduser --disabled-password --gecos "" ${USER} && \
    echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ------------------------------------------------------------
# Set-Up SSH with our Github deploy key
# ------------------------------------------------------------

ENV SSHDIR ${HOME}/.ssh/

RUN mkdir -p ${SSHDIR}

ADD ssh/config ${SSHDIR}/config
ADD ssh/id_rsa.mpi ${SSHDIR}/id_rsa
ADD ssh/id_rsa.mpi.pub ${SSHDIR}/id_rsa.pub
ADD ssh/id_rsa.mpi.pub ${SSHDIR}/authorized_keys

RUN chmod -R 600 ${SSHDIR}* && \
    chown -R ${USER}:${USER} ${SSHDIR}



# ------------------------------------------------------------
# Configure OpenMPI
# ------------------------------------------------------------

USER root

#RUN rm -fr ${HOME}/.openmpi && mkdir -p ${HOME}/.openmpi
#ADD default-mca-params.conf ${HOME}/.openmpi/mca-params.conf
#RUN chown -R ${USER}:${USER} ${HOME}/.openmpi

# ------------------------------------------------------------
# Copy MPI4PY example scripts
# ------------------------------------------------------------

ENV TRIGGER 1

ADD helloworldmpich.c ${HOME}/
ADD get_hosts.sh.txt ${HOME}/
RUN mv ${HOME}/get_hosts.sh.txt ${HOME}/machines
RUN chown -R ${USER}:${USER} ${HOME}/helloworldmpich.c

USER ${USER}
WORKDIR ${HOME}
RUN mpicc helloworldmpich.c -o helloworld
USER root
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]

