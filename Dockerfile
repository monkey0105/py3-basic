FROM ubuntu:14.04.3

# Install neccesary packages
RUN apt-get update && \
    apt-get install -y build-essential libsqlite3-dev sqlite3 bzip2 libbz2-dev libncurses5-dev libaio-dev libpq-dev postgresql-plpython3 unzip vim git git-core python-psycopg2 openssl libssl-dev libaio1 zlib1g zlib1g.dev postgresql-server-dev-9.3

# Copy Some neccesary files to the image
ADD requirements-total.txt Python-3.5.2.tgz instantclient-basic-linux.x64-11.2.0.4.0.zip instantclient-sdk-linux.x64-11.2.0.4.0.zip /opt/

# Install Python3.5.2 to images
WORKDIR /opt/Python-3.5.2/
RUN ./configure && \
    make && \
    make install && \
    rm /usr/bin/python && \
    ln -s /usr/local/bin/python3 /usr/bin/python && \
    ln -s /usr/local/bin/pip3 /usr/bin/pip  

# Install neccesary part of oracle client for cx_Oracle
RUN unzip /opt/instantclient-basic-linux.x64-11.2.0.4.0.zip -d /opt/ && \
    unzip /opt/instantclient-sdk-linux.x64-11.2.0.4.0.zip -d /opt/ && \
    rm /opt/instantclient-basic-linux.x64-11.2.0.4.0.zip && \
    rm /opt/instantclient-sdk-linux.x64-11.2.0.4.0.zip && \
    ln -s /opt/instantclient_11_2/libclntsh.so.11.1 /opt/instantclient_11_2/libclntsh.so && \
    echo "export ORACLE_HOME=/opt/instantclient_11_2" > /etc/profile.d/oracle.sh
ENV ORACLE_HOME=/opt/instantclient_11_2 \
LD_LIBRARY_PATH=/opt/instantclient_11_2:$LD_LIBRARY_PATH

WORKDIR /opt/
RUN git clone git://github.com/laurenz/oracle_fdw.git
WORKDIR /opt/oracle_fdw/
RUN make && \
    make install && \
    cp oracle_fdw.so /usr/lib/postgresql/9.3/lib/
WORKDIR /

# Install python packages from the requirement list 
RUN ldconfig && \
    pip install -r /opt/requirements-total.txt && \
    rm /opt/requirements-total.txt
