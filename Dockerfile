FROM apache/nifi:1.11.3

# Install debian packages, switch to root
USER 0

# COPY ./*.deb /

# RUN /usr/bin/dpkg -i /*.deb && /bin/rm -f /*.deb

# Configure the TZ to Asia/Jerusalem
RUN ln -s /usr/share/zoneinfo/Asia/Jerusalem /etc/localtime -f
ENV TZ=Asia/Jerusalem

# Add scripts to image
ADD sh/ ${NIFI_BASE_DIR}/scripts/sierra/
RUN chmod -R +x ${NIFI_BASE_DIR}/scripts/sierra/*.sh

# Switch to user nifi
USER 1000

WORKDIR ${NIFI_HOME}

ENTRYPOINT ["../scripts/sierra/run.sh"]
