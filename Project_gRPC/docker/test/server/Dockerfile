FROM golang:1.14.1 as builder
WORKDIR /app/
COPY * /app/
RUN CGO_ENABLED=0 go build -o 

FROM scratch
COPY --from=builder /app/greeter_server /greeter_server
EXPOSE 50051
CMD ["/greeter_server"]
