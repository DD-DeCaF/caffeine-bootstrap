FROM dddecaf/wsgi-base:debian

# The sympy cache causes significant memory leaks as it is currently used by
# optlang. Disable it by default.
ENV SYMPY_USE_CACHE=no

# CPLEX is provided externally; see the README
ARG CPLEX="cplex_128.tar.gz"

# Work in the /opt directory to persist the pip-compiled requirement list for
# child images to use.
WORKDIR /opt

COPY modeling-requirements.in ./
COPY cplex_128.tar.gz ./

RUN set -eux \
    # Install CPLEX first from the external source.
    && tar -xzf "${CPLEX}" \
    && pip --no-cache-dir install cplex_128/python/3.6/x86-64_linux \
    && rm -rf cplex_128* \
    # Compile all the modeling requirements. Note that `pip-compile` will use
    # the local installation of cplex.
    && pip-compile --generate-hashes \
        --output-file modeling-requirements.txt modeling-requirements.in \
    # Pre-install the compiled requirements to save some build time for child
    # images.
    && pip-sync modeling-requirements.txt \
    # Delete the pip cache to minimize image size.
    && rm -rf /root/.cache
