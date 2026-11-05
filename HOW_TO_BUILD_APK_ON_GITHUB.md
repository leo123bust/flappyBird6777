# Build the Flappy 67 APK on GitHub (no Flutter install needed)

You only need **2 files**:

1. `flappy_67_project.zip` - the whole game (upload it as-is, do NOT unzip it)
2. `build-apk.yml` - tells GitHub how to build the APK

## Steps (works from a phone browser or a computer)

1. Sign in at github.com and tap **+ > New repository**. Name it `flappy-67`,
   keep it empty (no README), then **Create repository**.
2. On the empty repo page tap **uploading an existing file**, choose
   `flappy_67_project.zip`, then **Commit changes**.
3. Tap **Add file > Create new file**. In the name box type exactly:

   `.github/workflows/build-apk.yml`

   (typing the slashes creates the folders). Paste the full contents of
   `build-apk.yml` into the big text box, then **Commit changes**.
4. Open the **Actions** tab. A run called **Build Android APK** starts by itself
   (about 5-10 minutes). A green check means it worked.
   You can also start it by hand: Actions > Build Android APK > **Run workflow**.
5. Download the APK: go back to the repo home page, open **Releases** (right
   side on desktop, or below the file list on phone), pick the newest one and
   tap **flappy_67.apk**.
   (Alternative: open the finished run and download the **flappy_67-apk**
   artifact - that one arrives as a zip.)
6. Open the APK on your Android phone. When asked, allow **Install unknown
   apps** for your browser/file manager. If Play Protect warns about an
   unknown app, choose **Install anyway** - the APK is signed with a debug key.

## Already uploaded the project files normally?

That works too. The workflow finds `pubspec.yaml` wherever it is. Just add
`.github/workflows/build-apk.yml` as in step 3.

## Using git on a computer

```bash
unzip flappy_67_project.zip && cd flappy_67
git init && git add . && git commit -m "Flappy 67"
git branch -M main
git remote add origin https://github.com/<you>/flappy-67.git
git push -u origin main
```
(The workflow file is already inside the zip at `.github/workflows/build-apk.yml`.)

## If the build fails (red X)

The game code has not been compiled before, so a first-run error is possible.
Open the failed run, click the red step, copy the last ~30 lines of the log and
send them to me - I'll fix the code and give you an updated zip.
