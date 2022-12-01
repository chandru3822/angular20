FROM golang:1.19.3 as builder
ENV upx_version 4.0.1
WORKDIR /go/html2pdf

RUN apt-get update && \
    apt-get install -y curl xz-utils && \
    mkdir -p ./upx/ && \
    curl -Ls https://github.com/upx/upx/releases/download/v${upx_version}/upx-${upx_version}-amd64_linux.tar.xz | tar Jx -C ./upx/ --strip-components 1 && \
    curl -Ls https://github.com/googlefonts/noto-emoji/raw/main/fonts/NotoColorEmoji.ttf -o NotoColorEmoji.ttf
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN make linux compress

FROM chromedp/headless-shell:latest
RUN apt-get update -y && \
    apt-get install -y dumb-init
COPY --from=builder /go/html2pdf/bin .
COPY --from=builder /go/html2pdf/NotoColorEmoji.ttf /usr/local/share/fonts/NotoColorEmoji.ttf
ENTRYPOINT ["dumb-init", "--"]
CMD ["./html2pdf_linux_amd64"]
