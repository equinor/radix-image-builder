FROM quay.io/buildah/stable:v1.31
RUN yum install strace -y
COPY cmd.sh /
CMD /cmd.sh
# TODO: mark git dir as safe for edit