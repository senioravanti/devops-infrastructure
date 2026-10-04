# https://gist.github.com/vdboor/4a596a4541e98318801461556a295ee7 
# Building the custom CloudNativePG image that has the vchord extension.
#
# docker rmi <старый тэг>
# docker build --progress=plain --push -t git.senioravanti.ru/root/cnpg-postgresql:18-trixie-vchord .

FROM ghcr.io/tensorchord/vchord-scratch:pg18-v1.1.1 AS ext
FROM ghcr.io/cloudnative-pg/postgresql:18-standard-trixie
COPY --from=ext ./usr/lib/postgresql/18/lib/vchord.so /usr/lib/postgresql/18/lib/
COPY --from=ext /usr/share/postgresql/18/extension/vchord* /usr/share/postgresql/18/extension/
