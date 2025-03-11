#!/bin/bash
# load array into a bash array
# need to output each entry as a single line
set -ex

readarray extensions < <(yq e -o=j -I=0 '.extensions[]' extensions.yaml )

if [ ! -f extensions.yaml ]; then
  echo extensions file not found
  exit 2
fi

default_extensions=$(yq e -I=0 '.default_extensions' extensions.yaml)
echo DEFAULT_EXTENSIONS: $default_extensions
mkdir /wheels
echo $default_extensions > /wheels/default_extensions.txt

for extension in "${extensions[@]}"; do
    # Get all relevant fields
    url=$(echo "$extension" | yq e '.url' -)
    branch_tag=$(echo "$extension" | yq e '.branch_tag' -)
    reqs=$(echo "$extension" | yq e '.requirements' -)
    name=$(echo "$extension" | yq e '.name' -)
    
    github_location=$(echo $url | cut -d'/' -f4-)
    full_reqs_url="https://raw.githubusercontent.com/$github_location/$branch_tag/$reqs"
    extension_name=$(echo $url | cut -d'/' -f5- )

    echo "-----"
    echo "Installing extension $github_location"
    echo "url: $url"
    echo "branch_tag: $branch_tag"
    echo "reqs: $full_reqs_url"

    #If error handeling
  if [ "${url}" = "" ] || [ "${url}" = "null" ];
    then
      echo "Url is empty add one"
      exit 1
  fi
  if [ "${branch_tag}" = "" ] || [ "${branch_tag}" = "null" ];
    then
      echo "Branch or tag is missing add one"
      exit 1
  fi
  if [ "${name}" = "" ] || [ "${name}" = "null" ];
    then
      echo "Name of the extension is missing add one"
      exit 1
  fi
    # Create wheel for extension
    pip wheel --wheel-dir=/wheels git+$url@$branch_tag#egg=$extension_name
    # Create wheels for reqs
  if [ "${reqs}" = "" ] || [ "${reqs}" = "null" ];
    then 
      echo "skipping extension $github_location has no reqs";
    else
      pip wheel --wheel-dir=/wheels -r $full_reqs_url
      curl -o "/wheels/$extension_name-requirements.txt" "$full_reqs_url"
      cat /wheels/$extension_name-requirements.txt >> /wheels/full-requirements.txt
  fi
      echo $extension_name >> /wheels/extensions.txt
      echo $name >> /wheels/extension_ini_names.txt
  
done