# Basic git diff summarizer
alias gai-summary="git diff | ollama run git-change-g3n2b"

# Full git commit message generation pipeline
alias gai-msg="git diff --cached | ollama run git-change-g3n2b | ollama run git-commit-g3n2b"

# Alternative: analyze all changes (not just staged)
alias gai-all="git diff | ollama run git-change-g3n2b | ollama run git-commit-g3n2b"

# Interactive version - shows summary first, then generates commit message
alias gai-interactive='echo "=== DIFF SUMMARY ===" && git diff --cached | ollama run git-change-g3n2b && echo -e "\n=== COMMIT MESSAGE OPTIONS ===" && git diff --cached | ollama run git-change-g3n2b | ollama run git-commit-g3n2b'

# Shorter aliases for frequent use
alias gaids="git diff --cached | ollama run git-change-g3n2b"
alias gaicm="git diff --cached | ollama run git-change-g3n2b | ollama run git-commit-g3n2b"

# Function for creating commit with AI-generated message
gai-commit() {
    if [[ -z $(git diff --cached --name-only) ]]; then
        echo "No staged changes found. Stage your changes first with 'git add'."
        return 1
    fi
    
    echo "Analyzing staged changes..."
    local commit_msg=$(git diff --cached | ollama run git-diff-summarizer | ollama run commit-msg-generator)
    
    echo -e "\nGenerated commit message:\n$commit_msg"
    echo -e "\nProceed with this commit? (y/n)"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        git commit -m "$commit_msg"
        echo "Committed successfully!"
    else
        echo "Commit cancelled."
    fi
}

# Interactive version - shows summary first, then generates commit message
alias yadmai-interactive='echo "=== DIFF SUMMARY ===" && git diff --cached | ollama run git-change-g3n2b && echo -e "\n=== COMMIT MESSAGE OPTIONS ===" && git diff --cached | ollama run git-change-g3n2b | ollama run git-commit-g3n2b'
