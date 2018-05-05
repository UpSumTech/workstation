#!/usr/bin/env bash

all_available_profiles() {
  local profiles=( \
    "admin" \
    "superuser" \
    "developer" \
  )
  echo "${profiles[@]}"
}

which_profile_is_active() {
  if [[ ! -z "$CURRENT_PROFILE" ]]; then
    echo "Current active profile is $CURRENT_PROFILE"
  else
    echo "No currently active profile"
  fi
}

clean_active_profile() {
  case $CURRENT_PROFILE in
  developer)
    deactivate_profile_for_developer
    echo "Unset current profile from developer"
    ;;
  admin)
    deactivate_profile_for_admin
    echo "Unset current profile from admin"
    ;;
  superuser)
    deactivate_profile_for_superuser
    echo "Unset current profile from superuser"
    ;;
  *)
    echo "No valid profile currently active"
    ;;
  esac
}

activate_profile_for_developer() {
  clean_active_profile
  export AWS_ACCESS_KEY_ID="$DEVELOPER_AWS_ACCESS_KEY_ID"
  export AWS_SECRET_ACCESS_KEY="$DEVELOPER_AWS_SECRET_ACCESS_KEY"
  export AWS_ACCOUNT_ID="$DEVELOPER_AWS_ACCOUNT_ID"
  export AWS_ACCESS_KEY="$DEVELOPER_AWS_ACCESS_KEY_ID"
  export AWS_SECRET_KEY="$DEVELOPER_AWS_SECRET_ACCESS_KEY"
  export AWS_DEFAULT_REGION="$DEVELOPER_AWS_DEFAULT_REGION"
  export DEPLOY_GITHUB_TOKEN="$DEVELOPER_DEPLOY_GITHUB_TOKEN"
  export DOCKERHUB_USERNAME="$DEVELOPER_DOCKERHUB_USERNAME"
  export DOCKERHUB_PASSWORD="$DEVELOPER_DOCKERHUB_PASSWORD"
  export GITHUB_USERNAME="$DEVELOPER_GITHUB_USERNAME"
  export BINTRAY_USERNAME="$DEVELOPER_BINTRAY_USERNAME"
  export BINTRAY_API_KEY="$DEVELOPER_BINTRAY_API_KEY"
  export BINTRAY_REPO_NAME="$DEVELOPER_BINTRAY_REPO_NAME"
  activate_profile_helper "developer"
}

deactivate_profile_for_developer() {
  deactivate_profile_helper
}

activate_profile_for_admin() {
  clean_active_profile
  export AWS_ACCESS_KEY_ID="$ADMIN_AWS_ACCESS_KEY_ID"
  export AWS_SECRET_ACCESS_KEY="$ADMIN_AWS_SECRET_ACCESS_KEY"
  export AWS_ACCOUNT_ID="$ADMIN_AWS_ACCOUNT_ID"
  export AWS_ACCESS_KEY="$ADMIN_AWS_ACCESS_KEY_ID"
  export AWS_SECRET_KEY="$ADMIN_AWS_SECRET_ACCESS_KEY"
  export AWS_DEFAULT_REGION="$ADMIN_AWS_DEFAULT_REGION"
  export DEPLOY_GITHUB_TOKEN="$ADMIN_DEPLOY_GITHUB_TOKEN"
  export DOCKERHUB_USERNAME="$ADMIN_DOCKERHUB_USERNAME"
  export DOCKERHUB_PASSWORD="$ADMIN_DOCKERHUB_PASSWORD"
  export GITHUB_USERNAME="$ADMIN_GITHUB_USERNAME"
  export BINTRAY_USERNAME="$ADMIN_BINTRAY_USERNAME"
  export BINTRAY_API_KEY="$ADMIN_BINTRAY_API_KEY"
  export BINTRAY_REPO_NAME="$ADMIN_BINTRAY_REPO_NAME"
  activate_profile_helper "admin"
}

deactivate_profile_for_admin() {
  deactivate_profile_helper
}

activate_profile_for_superuser() {
  clean_active_profile
  export AWS_ACCESS_KEY_ID="$SUPERUSER_AWS_ACCESS_KEY_ID"
  export AWS_SECRET_ACCESS_KEY="$SUPERUSER_AWS_SECRET_ACCESS_KEY"
  export AWS_ACCOUNT_ID="$SUPERUSER_AWS_ACCOUNT_ID"
  export AWS_ACCESS_KEY="$SUPERUSER_AWS_ACCESS_KEY_ID"
  export AWS_SECRET_KEY="$SUPERUSER_AWS_SECRET_ACCESS_KEY"
  export AWS_DEFAULT_REGION="$SUPERUSER_AWS_DEFAULT_REGION"
  export DEPLOY_GITHUB_TOKEN="$SUPERUSER_DEPLOY_GITHUB_TOKEN"
  export DOCKERHUB_USERNAME="$SUPERUSER_DOCKERHUB_USERNAME"
  export DOCKERHUB_PASSWORD="$SUPERUSER_DOCKERHUB_PASSWORD"
  export GITHUB_USERNAME="$SUPERUSER_GITHUB_USERNAME"
  export BINTRAY_USERNAME="$SUPERUSER_BINTRAY_USERNAME"
  export BINTRAY_API_KEY="$SUPERUSER_BINTRAY_API_KEY"
  export BINTRAY_REPO_NAME="$SUPERUSER_BINTRAY_REPO_NAME"
  activate_profile_helper "superuser"
}

deactivate_profile_for_superuser() {
  deactivate_profile_helper
}

activate_profile_helper() {
  export CURRENT_PROFILE="$1"
  echo "Set current profile to $CURRENT_PROFILE"
}

deactivate_profile_helper() {
  unset CURRENT_PROFILE
  unset AWS_ACCESS_KEY_ID
  unset AWS_SECRET_ACCESS_KEY
  unset AWS_ACCOUNT_ID
  unset AWS_DEFAULT_REGION
  unset DEPLOY_GITHUB_TOKEN
  unset DOCKERHUB_USERNAME
  unset DOCKERHUB_PASSWORD
  unset GITHUB_USERNAME
  unset BINTRAY_USERNAME
  unset BINTRAY_API_KEY
  unset BINTRAY_REPO_NAME
}

activate_help() {
  echo "
    Valid profiles are : $(_all_available_profiles)
    Valid options for calling acivate profile are
      activate_profile_for_developer
      deactivate_profile_for_developer
      activate_profile_for_admin
      deactivate_profile_for_admin
      activate_profile_for_superuser
      deactivate_profile_for_superuser
      activate_help
      all_available_profiles
      clean_active_profile
  "
}

export SOURCED_ACTIVATE_PROFILE=1
