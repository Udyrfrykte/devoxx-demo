FROM maven:3.3.9-jdk-8

ARG COMMIT
ARG BUILD_DATE
ARG PETCLINIC_VERSION

LABEL commit.petclinic=$COMMIT build_date.petclinic=$BUILD_DATE version.petclinic=$PETCLINIC_VERSION

ADD . /usr/src/app
WORKDIR /usr/src/app

EXPOSE 8080

CMD ["mvn", "spring-boot:run"]
