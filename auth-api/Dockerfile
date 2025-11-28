FROM golang:1.21-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -o auth-api .


FROM gcr.io/distroless/base-debian12

WORKDIR /app

EXPOSE 8081
COPY --from=builder /app/auth-api .
CMD ["./auth-api"]