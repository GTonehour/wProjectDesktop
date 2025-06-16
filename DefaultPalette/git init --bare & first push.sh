#!/bin/bash
function invoke_command() {
    local project="$1"
    local spawn_wt="$2"
    local project_path="$3"
    local wt_located="$4"
    
    "$PROJECTS/docs/git push initialize remote bare.sh"
}