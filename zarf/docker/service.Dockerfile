FROM golang:1.22.7 as build_sales-api
ENV CGO_ENABLED=0
ARG BUILD_REF

#RUN mkdir /service
#COPY go.* /service/
#WORKDIR /service
#RUN go mod download

COPY . /service

WORKDIR /service/app/services/sales-api
RUN go build -ldflags "-X main.build=${BUILD_REF}"

FROM alpine:3.20
ARG BUILD_DATE
ARG BUILD_REF
RUN addgroup -g 1000 -S sales && \
    adduser -u 1000 -h /service -G sales -S sales
#COPY --from=build_sales --chown=sales:sales /service/api/cmd/tooling/admin/admin /service/admin
#COPY --from=build_sales --chown=sales:sales /service/api/cmd/services/sales/sales /service/sales
COPY --from=build_sales-api --chown=sales:sales /service/app/services/sales-api/sales-api /service/sales-api
WORKDIR /service
USER sales
CMD ["./sales"]

LABEL org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.title="sales-api" \
      org.opencontainers.image.revision="${BUILD_REF}" \

