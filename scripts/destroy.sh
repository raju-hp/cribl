ENV=$1
export AWS_PROFILE=$2
: ${TERRAFORM:=terraform}

if [ -z "$ENV" ]
then
    echo "Usage: init.sh <env> <aws-profile>"
    exit 1
fi

$TERRAFORM init --upgrade -reconfigure --backend-config=./env/$ENV/$ENV.tfbackend --var-file=./env/$ENV/$ENV.tfvars

if [ -n "$UNLOCK_KEY" ]
then
    ${TERRAFORM} force-unlock $UNLOCK_KEY
fi

${TERRAFORM} destroy ${AUTO_APPROVE} --var-file=./env/$ENV/$ENV.tfvars