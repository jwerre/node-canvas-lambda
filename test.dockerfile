ARG NODE_VERSION=16

FROM public.ecr.aws/lambda/nodejs:${NODE_VERSION}-arm64

# Copy function code
COPY lib /opt/lib
COPY nodejs /opt/nodejs
COPY test.js ${LAMBDA_TASK_ROOT}

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "test.handler" ]