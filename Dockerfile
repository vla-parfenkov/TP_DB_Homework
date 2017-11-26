FROM ubuntu:16.04
MAINTAINER v.parfenkov
RUN apt-get -y update
RUN apt-get install -y openjdk-8-jdk-headless
RUN apt-get install -y postgresql
RUN apt-get install -y maven

USER postgres

RUN /etc/init.d/postgresql start &&\
    psql --command "CREATE USER vlad WITH SUPERUSER PASSWORD 'vlad';" &&\
    createdb -E UTF8 -T template0   db_forum &&\
    /etc/init.d/postgresql stop

EXPOSE 5432

VOLUME ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

USER root

ENV WORK /opt/TP_DB_Homework
ADD ./ $WORK/

WORKDIR $WORK
RUN mvn package

EXPOSE 5000


CMD service postgresql start && java -Xmx300M -Xmx300M -jar $WORK/target/TP_DB_Homework-1.0-SNAPSHOT.jar

