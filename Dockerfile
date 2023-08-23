# Base image
FROM runpod/pytorch:3.10-2.0.0-117

SHELL ["/bin/bash", "-c"]

WORKDIR /

# Environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONBUFFERED 1
ENV DEBIAN_FRONTEND noninteractive

# Install packages
COPY builder/packages.sh /packages.sh
RUN /bin/bash /packages.sh && rm /packages.sh

# Install Python dependencies (Worker Template)
COPY builder/requirements.txt /requirements.txt
RUN pip install --upgrade pip && \
    pip install -r /requirements.txt && \
    rm /requirements.txt

# Fetch model
COPY builder/cache_models.py /cache_models.py
RUN python /cache_models.py
RUN rm /cache_models.py

ADD src .

# These ENV VARS are used to allow the worker to access S3
ARG AWS_S3_BUCKET_WORKER
ENV BUCKET_ENDPOINT_URL ${AWS_S3_BUCKET_WORKER}
ARG AWS_ACCESS_KEY_ID_WORKER
ENV BUCKET_ACCESS_KEY_ID ${AWS_ACCESS_KEY_ID_WORKER}
ARG AWS_SECRET_ACCESS_KEY_WORKER
ENV BUCKET_SECRET_ACCESS_KEY ${AWS_SECRET_ACCESS_KEY_WORKER}

CMD [ "python", "-u", "/rp_handler.py" ]
