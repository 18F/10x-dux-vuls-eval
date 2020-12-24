ARG SRCDIR=/usr/local/bin
ARG DESTDIR=/usr/local/bin
ARG ALPINE_VERSION=3.12.1
ARG CVEDB_OWNER=vuls
ARG CVEDB_REPO=go-cve-dictionary
ARG CVEDB_VERSION=0.5.6
ARG EDB_OWNER=vuls
ARG EDB_REPO=go-exploitdb
ARG EDB_VERSION=0.1.2
ARG GOST_OWNER=vuls
ARG GOST_REPO=gost
ARG GOST_VERSION=latest
ARG OVAL_OWNER=vuls
ARG OVAL_REPO=goval-dictionary
ARG OVAL_VERSION=0.2.16
ARG MSFDB_OWNER=vuls
ARG MSFDB_REPO=go-msfdb
ARG MSFDB_VERSION=latest
ARG VULS_OWNER=vuls
ARG VULS_REPO=vuls
ARG VULS_VERSION=0.14.0
ARG VULSUI_OWNER=vuls
ARG VULSUI_REPO=vulsrepo
ARG VULSUI_VERSION=latest

FROM ${CVEDB_OWNER}/${CVEDB_REPO}:${CVEDB_VERSION} as cve
FROM ${EDB_OWNER}/${EDB_REPO}:${EDB_VERSION} as edb
FROM ${GOST_OWNER}/${GOST_REPO}:${GOST_VERSION} as gost
FROM ${MSFDB_OWNER}/${MSFDB_REPO}:${MSFDB_VERSION} as msfdb
FROM ${OVAL_OWNER}/${OVAL_REPO}:${OVAL_VERSION} as oval
FROM ${VULS_OWNER}/${VULS_REPO}:${VULS_VERSION} as vuls
FROM ${VULSUI_OWNER}/${VULSUI_REPO}:${VULSUI_VERSION} as vulsui


FROM alpine:${ALPINE_VERSION}
# Why do we need to duplicate and pull default ARG values from above first
# FROM?
# So they get set to default value; they are reset to blank with every next
# FROM context.
#
# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG SRCDIR
ARG DESTDIR
ARG CVEDB_REPO
ARG EDB_REPO
ARG GOST_REPO
ARG MSFDB_REPO
ARG OVAL_REPO
ARG VULS_REPO
ARG VULSUI_REPO

COPY --from=cve ${SRCDIR}/${CVEDB_REPO} ${DESTDIR}/${CVEDB_REPO}
RUN which ${CVEDB_REPO}

COPY --from=edb ${SRCDIR}/${EDB_REPO} ${DESTDIR}/${EDB_REPO}
RUN which ${EDB_REPO}

COPY --from=gost ${SRCDIR}/${GOST_REPO} ${DESTDIR}/${GOST_REPO}
RUN which ${GOST_REPO}

COPY --from=msfdb ${SRCDIR}/${MSFDB_REPO} ${DESTDIR}/${MSFDB_REPO}
RUN which ${MSFDB_REPO}

COPY --from=oval ${SRCDIR}/${OVAL_REPO} ${DESTDIR}/${OVAL_REPO}
RUN which ${OVAL_REPO}

COPY --from=vuls ${SRCDIR}/${VULS_REPO} ${DESTDIR}/${VULS_REPO}
RUN which ${VULS_REPO}

COPY --from=vulsui ${SRCDIR}/${VULSUI_REPO}-server ${DESTDIR}/${VULSUI_REPO}-server
RUN which ${VULSUI_REPO}-server