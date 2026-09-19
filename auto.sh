username="ritik902"
token="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"
url="https://${username}:${token}@github.com/ritik902/My_Portfolio"

git remote set-url origin "$url"

git status
git add .
git commit -m "2"
git push

echo "Code pushed successfully!"
