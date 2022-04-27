#TODO: add builder for project
FROM chromedp/headless-shell:latest
#    curl -Ls "https://github.com/googlefonts/noto-emoji/raw/$NOTO_COLOR_EMOJI_VERSION/fonts/NotoColorEmoji.ttf" -o /usr/local/share/fonts/NotoColorEmoji.ttf &&\
#TODO: upx?
RUN apt-get update && apt-get install -y dumb-init curl
RUN curl -OL https://go.dev/dl/go1.17.6.linux-amd64.tar.gz && tar -C /usr/local/ -xvf go1.17.6.linux-amd64.tar.gz
#COPY build/html2pdf .
ENTRYPOINT ["dumb-init", "--"]
#CMD ["./html2pdf"]
