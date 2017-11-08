FROM registry.udd.bogops.io/devs/alpine:3

ADD app /
ARG COMMIT="No Version"

LABEL app.language=golang app.commit=$COMMIT app.name=app-metrics

EXPOSE 8080
ENTRYPOINT ["/app"]
