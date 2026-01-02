# AWS_CODE_ARTIFACT
export AWS_ACCOUNT_ID=283966372511
export AWS_PROFILE=shm-nsd-dev-deploy
export AWS_REGION=ap-northeast-1
export CODE_ARTIFACT_DOMAIN=shm-nsd
export CODE_ARTIFACT_REPOSITORY=nsd-be-prd

# cat << EOF
# AWS_ACCOUNT_ID=[${AWS_ACCOUNT_ID}]
# AWS_PROFILE=[${AWS_PROFILE}]
# AWS_REGION=[${AWS_REGION}]
# CODE_ARTIFACT_DOMAIN=[${CODE_ARTIFACT_DOMAIN}]
# CODE_ARTIFACT_REPOSITORY=[${CODE_ARTIFACT_REPOSITORY}]
# EOF

# ログイン
shm-login() {
  aws codeartifact login \
    --tool npm \
    --domain-owner ${AWS_ACCOUNT_ID} \
    --region ${AWS_REGION} \
    --domain ${CODE_ARTIFACT_DOMAIN} \
    --repository ${CODE_ARTIFACT_REPOSITORY} \
    --namespace ${CODE_ARTIFACT_DOMAIN}

  export CODE_ARTIFACT_AUTH_TOKEN=$(aws codeartifact get-authorization-token \
    --domain-owner ${AWS_ACCOUNT_ID} \
    --region ${AWS_REGION} \
    --domain ${CODE_ARTIFACT_DOMAIN} \
    --query authorizationToken \
    --output text)
}

shm-list() {
  aws codeartifact list-packages \
    --domain-owner ${AWS_ACCOUNT_ID} \
    --domain ${CODE_ARTIFACT_DOMAIN} \
    --repository ${CODE_ARTIFACT_REPOSITORY}
}

shm-item() {
  local package_name=$1

  if [ -z "$package_name" ]; then
    echo "Error: Package name is required."
    return 1
  fi

  aws codeartifact list-package-versions \
    --format npm \
    --domain-owner ${AWS_ACCOUNT_ID} \
    --domain ${CODE_ARTIFACT_DOMAIN} \
    --namespace ${CODE_ARTIFACT_DOMAIN} \
    --repository ${CODE_ARTIFACT_REPOSITORY} \
    --package "${package_name}" \
    --max-results 2 --sort-by PUBLISHED_TIME
}

check-login() {
  aws codeartifact get-authorization-token --domain ${CODE_ARTIFACT_DOMAIN} --domain-owner ${AWS_ACCOUNT_ID}
}
