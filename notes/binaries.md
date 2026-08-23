Binaries would be released of only the desktop apps and the apk. An install script could be made for linux which is invoked by curl, and does all the downloading and verification (so the project doesn't depend on a repo of some distro), as for Windows, I need to plan about it and lastly for Android, nothing done here. The rest (api, web, docs) would be ideally ran by docker, with only the needed services, from docker compose.

Furthermore, the binaries would only be distributed on GH, and official site (along with curl one liner).
