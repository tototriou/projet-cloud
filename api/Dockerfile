FROM python:3

WORKDIR /usr/src/app

COPY . .

EXPOSE 8080

ENV CELERY_BROKER_URL=amqp://aristide-briand:lZvWCCWT8lvnHpAJYvue@queue.internal.100do.se:5672/aristide-briand
ENV S3_ENDPOINT_URL=http://s3.100do.se/
ENV AWS_ACCESS_KEY_ID=aristide-briand 
ENV AWS_SECRET_ACCESS_KEY=sRYCIwNSULz9CAiNv5oz



RUN apt update && apt-get install -y curl
RUN curl -sSL https://install.python-poetry.org | python3 -
RUN pip install poetry
RUN pip install .
RUN poetry install


CMD ["poetry" , "run" , "app" , "poetry" , "run" , "celery", "worker", "--app", "image_api.worker.app"]