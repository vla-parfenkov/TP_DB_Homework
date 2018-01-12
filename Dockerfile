FROM ubuntu:16.04
MAINTAINER v.parfenkov
RUN apt-get -y update
RUN apt-get install -y openjdk-8-jdk-headless
RUN apt-get install -y maven
ENV PGVER 9.5
RUN apt-get install -y postgresql-$PGVER

USER postgres

RUN /etc/init.d/postgresql start &&\
    psql --command "CREATE USER vlad WITH SUPERUSER PASSWORD 'vlad';" &&\
    createdb -E UTF8 -T template0   db_forum &&\
    /etc/init.d/postgresql stop
    
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/$PGVER/main/pg_hba.conf

RUN echo "listen_addresses='*'" >> /etc/postgresql/$PGVER/main/postgresql.conf
RUN echo "synchronous_commit = off" >> /etc/postgresql/$PGVER/main/postgresql.conf

EXPOSE 5432

VOLUME ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

USER root

ENV WORK /opt/TP_DB_Homework
ADD ./ $WORK/

WORKDIR $WORK
RUN mvn package

EXPOSE 5000


CMD service postgresql start && java -Xmx300M -Xmx300M -jar $WORK/target/TP_DB_Homework-1.0-SNAPSHOT.jar

