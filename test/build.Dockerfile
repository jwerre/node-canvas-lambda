FROM lambci/lambda:build-nodejs12.x

ENV APP_DIR /var/task

WORKDIR $APP_DIR
