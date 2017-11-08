FROM golang:1.7.5-wheezy

ADD . /go/src/github.com/optiopay/klar
WORKDIR  /go/src/github.com/optiopay/klar/
RUN git checkout v1.2.1 && go build . && cp klar /usr/local/bin
WORKDIR /go
