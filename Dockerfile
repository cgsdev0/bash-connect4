FROM node:20-alpine3.17 as tailwind
COPY . /app
WORKDIR /app
RUN npx tailwindcss -i /app/static/style.css -o /app/build.css --minify

FROM rust:1.71 as rust
COPY . /app
WORKDIR /app/lib/evaluation/
RUN cargo build --release

FROM ubuntu as prod
ENV DEV=false
RUN apt-get update && apt-get install ucspi-tcp
EXPOSE 3000
COPY . /app
WORKDIR /app

COPY --from=tailwind /app/build.css /app/static/tailwind.css
RUN mkdir -p /app/lib/evaluation/target/release
COPY --from=rust /app/lib/evaluation/target/release/evaluation /app/lib/evaluation/target/release/evaluation

CMD [ "/app/start.sh" ]
