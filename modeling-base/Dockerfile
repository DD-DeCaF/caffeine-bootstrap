FROM dddecaf/wsgi-base:debian

# The sympy cache causes significant memory leaks as it is currently used by
# optlang. Disable it by default.
ENV SYMPY_USE_CACHE=no

# Work in the /opt directory to persist the pip-compiled requirement list for
# child images to use.
WORKDIR /opt

COPY modeling-requirements.in ./

RUN set -eux \
    # Compile all the modeling requirements. Note that `pip-compile` will use
    # the local installation of cplex.
    && pip-compile --generate-hashes \
        --output-file modeling-requirements.txt modeling-requirements.in \
    # Pre-install the compiled requirements to save some build time for child
    # images.
    && pip-sync modeling-requirements.txt \
    # Delete the pip cache to minimize image size.
    && rm -rf /root/.cache
