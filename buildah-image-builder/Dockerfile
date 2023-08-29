FROM quay.io/buildah/stable:v1.30.0
RUN yum install strace -y
COPY cmd.sh /
CMD ["echo, “hello”]
#CMD /cmd.sh
# TODO: mark git dir as safe for edit