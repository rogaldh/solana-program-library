# docker build should be executed at the core `solana-program-library` directory:
# `docker build --build-arg=MAIN_ROUTER_ID=<%main_router_id%> --build-arg=<%main_router_admin%> . -f ./ci/farm-rpc.Dockerfile -t farm-rpc`
FROM solanalabs/solana:v1.10.8 as solana-cli
FROM solanalabs/rust:1.60.0 as compile

ARG MAIN_ROUTER_ID
ARG MAIN_ROUTER_ADMIN

ENV MAIN_ROUTER_ID=${MAIN_ROUTER_ID}
ENV MAIN_ROUTER_ADMIN=${MAIN_ROUTER_ADMIN}

WORKDIR /mnt

COPY --from=solana-cli /usr/bin/sdk /usr/local/bin/sdk

COPY . spl

RUN cd spl/farms/farm-rpc && cargo build

FROM solanalabs/solana:v1.10.8

WORKDIR /

COPY --from=compile /mnt/spl/farms/target/debug/solana-farm-rpc solana-farm-rpc
COPY --from=compile /mnt/spl/farms/farm-rpc/static static

RUN apt-get -y update && apt-get -y install openssl ca-certificates sqlite3

EXPOSE 9090

CMD ["-f https://api.mainnet-beta.solana.com", "-u http://0.0.0.0:9090"]
ENTRYPOINT ["/solana-farm-rpc"]
