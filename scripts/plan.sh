ENV=$1
export AWS_PROFILE=$2
: ${TERRAFORM:=terraform}

if [ -z "$ENV" ]
then
    echo "Usage: init.sh <env> <aws-profile>"
    exit 1
fi

$TERRAFORM init --upgrade -reconfigure --backend-config=./env/$ENV/$ENV.tfbackend --var-file=./env/$ENV/$ENV.tfvars
$TERRAFORM plan --var-file=./env/$ENV/$ENV.tfvars