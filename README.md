# How to Set Up a New GitHub Repository and Development Branch

## Steps:

1. Create a project directory

```bash
mkdir new-project
cd new-project
```

2. Initialize a Git repository

```bash
git init
```

3. Create a new public repository on GitHub

Go to GitHub → New repository → Name: new-project → Public → Create repository

Copy the repository URL, e.g.:
git@github.com:your-username/new-project.git (SSH) or
https://github.com/your-username/new-project.git (HTTPS)

4. Add GitHub as a remote origin

```bash
git remote add origin git@github.com:your-username/new-project.git
```

5. Create the README.md file with initial content

```bash
echo "# new-project" > README.md
```

6. Stage the README.md file

```bash
git add README.md
```

7. Commit the changes with the message “init”

```bash
git commit -m "init"
```

8. Push to the main branch (to create it on GitHub)

```bash
git branch -M main
git push -u origin main
```

9. Create a new branch called 'development' and switch to it

```bash
git checkout -b development
```

10. Add instructions to the README.md

```bash
echo "## Instructions added on development branch" >> README.md
```

11. Stage the changes

```bash
git add README.md
```

12. Commit the changes using Smart Commit (for Jira ticket PROM-42164)

```bash
git commit -m "PROM-42164 #done Added instructions to README.md"
```

13. Push the development branch to GitHub

```bash
git push -u origin development
```

14. Switch back to the main branch

```bash
git checkout main
```

15. Merge the development branch into main

```bash
git merge development
```

16. Push the updated main branch to GitHub

```bash
git push
```

17. Check the repository status

```bash
git status
```
