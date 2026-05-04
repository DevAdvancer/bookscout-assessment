# How to Push This Project to GitHub

This project is a Git repository on the `main` branch. Use the steps below to push it to a private GitHub repository.

## 1. Create a Private GitHub Repository

1. Go to GitHub.
2. Create a new repository.
3. Set visibility to **Private**.
4. Do not initialize it with a README, `.gitignore`, or license because this project already has those files.

Example repository name:

```sh
bookscout-assessment
```

## 2. Check Local Git Status

From the project folder:

```sh
git status
```

If files are changed, stage and commit them:

```sh
git add .
git commit -m "Update assessment project"
```

## 3. Add the GitHub Remote

Replace `YOUR_USERNAME` and `REPOSITORY_NAME` with your GitHub username and repo name:

```sh
git remote add origin https://github.com/YOUR_USERNAME/REPOSITORY_NAME.git
```

If `origin` already exists, update it:

```sh
git remote set-url origin https://github.com/YOUR_USERNAME/REPOSITORY_NAME.git
```

Check the remote:

```sh
git remote -v
```

## 4. Push to GitHub

Push the local `main` branch:

```sh
git push -u origin main
```

After the first push, future pushes can use:

```sh
git push
```

## 5. Invite the Hiring Manager

1. Open the GitHub repository.
2. Go to **Settings**.
3. Open **Collaborators and teams**.
4. Click **Add people**.
5. Enter the hiring manager's GitHub username.
6. Send the invitation.

## 6. Share the Repository URL

After pushing and inviting the hiring manager, share the private repository URL.

For this project, the current repository URL is:

```text
https://github.com/DevAdvancer/bookscout-assessment
```
