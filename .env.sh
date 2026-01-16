#!/bin/bash

vaultctl login 
eval $(vaultctl export-vault)
eval $(vaultctl export-users-cbi NEXUS_USERNAME NEXUS_PASSWORD)
export NEXUS_ENV="prod"