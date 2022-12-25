FROM golang:1.14.1 as builder
WORKDIR /app/
COPY * /app/
RUN CGO_ENABLED=0 go build -o /app/greeter_client .

FROM scratch
COPY --from=builder /app/greeter_client /greeter_client
CMD ["/greeter_client"]
