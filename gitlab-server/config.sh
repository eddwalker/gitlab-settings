# Place this config file in the same directory as clean-registry.sh and name it "config.sh"

# Gitlab URL
GITLAB_URL="https://gitlab.local"  

# Gitlab Personal Access Token
GITLAB_AUTH_TOKEN="glpat-xW_HU_vEc2vaXqJFfyro"

# Gitlab Project ID (can find this number on Project Overview page)
GITLAB_PROJECT_ID="5"  

# Gitlab Registry ID. This is per project, so if a project has a single registry, the Registry ID is 1
GITLAB_REGISTRY_ID=15

# Delete the tag / image if older than this many days
EXPIRATION_DAYS="1" 

# OPTIONAL: Regex for tags/images to include. Anything not matching regex will not be removed
INCLUDE_FOR_DELETION=".*"

# OPTIONAL: Regex for tags/images to exclude. Anything matching this regex will not be removed. 
# Note - "latest" tag is always retained
EXCLUDE_FROM_DELETION=""

# Set this to "TRUE" to run the script in test mode, which will do everything except actually delete
# images / tags
DRY_RUN="FALSE"
