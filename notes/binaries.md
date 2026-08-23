Binaries would be released of only the desktop apps and the apk. An install script could be made for linux which is invoked by curl, and does all the downloading and verification (so the project doesn't depend on a repo of some distro), as for Windows, I need to plan about it and lastly for Android, nothing done here. The rest (api, web, docs) would be ideally ran by docker, with only the needed services, from docker compose.

Furthermore, the binaries would only be distributed on GH, and official site (along with curl one liner).

async function downloadLatestRelease(extension) {
  // Query GitHub's API for the latest release metadata
  const response = await fetch('https://api.github.com/repos/Abled-Taha/iron_book/releases/latest');
  const release = await response.json();

  // Find the asset matching the desired file format (.apk, .zip, etc.)
  const asset = release.assets.find(a => a.name.endsWith(extension));

  if (asset) {
    window.location.href = asset.browser_download_url;
  } else {
    alert('Release file not found!');
  }
}

This is the pseudo code for downloading a release from the docs site.
The extension can be .exe for the installer but the gh will have to make an installer with innosetup and upload that too. And for linux, just a curl command is sufficient.
This next function is for dynamically getting the latest pre release

async function downloadLatestPreRelease(extension) {
  // Get ALL releases (returns an array sorted by date, including pre-releases)
  const res = await fetch('https://api.github.com/repos/Abled-Taha/iron_book/releases');
  const releases = await res.json();

  // Grab the very top one (the most recent release or pre-release)
  const latestBuild = releases[0];

  // Find the file (e.g., .apk, win-x64.zip, etc.)
  const asset = latestBuild.assets.find(a => a.name.endsWith(extension));

  if (asset) {
    window.location.href = asset.browser_download_url;
  }
}
