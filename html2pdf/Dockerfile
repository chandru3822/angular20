FROM golang:1.18.1 as builder
ENV upx_version 3.96
WORKDIR /go/html2pdf

RUN apt-get update && \
    apt-get install -y curl xz-utils && \
    mkdir -p ./upx/ && \
    curl -Ls https://github.com/upx/upx/releases/download/v${upx_version}/upx-${upx_version}-amd64_linux.tar.xz | tar Jx -C ./upx/ --strip-components 1

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN make linux compress

FROM chromedp/headless-shell:latest
RUN apt-get update && apt-get install -y dumb-init curl && \
     curl -Ls "https://github.com/googlefonts/noto-emoji/raw/main/fonts/NotoColorEmoji.ttf" -o /usr/local/share/fonts/NotoColorEmoji.ttf

COPY --from=builder /go/html2pdf/bin .
ENTRYPOINT ["dumb-init", "--"]
CMD ["./html2pdf_linux_amd64"]
