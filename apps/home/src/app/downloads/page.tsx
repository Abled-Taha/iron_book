'use client';

async function downloadLatestPreRelease(extension: string) {
  try {
    // Get ALL releases (returns an array sorted by date, including pre-releases)
    const res = await fetch('https://api.github.com/repos/Abled-Taha/iron_book/releases');
    const releases = await res.json();

    if (!Array.isArray(releases) || releases.length === 0) {
      alert('No releases found.');
      return;
    }

    // Grab the very top one (the most recent release or pre-release)
    const latestBuild = releases[0];

    // Find the file (e.g., .apk, .exe, etc.)
    const asset = latestBuild.assets?.find((a: { name: string }) => a.name.endsWith(extension));

    if (asset) {
      window.location.href = asset.browser_download_url;
    } else {
      alert(`Pre-release file with extension "${extension}" not found.`);
    }
  } catch (error) {
    console.error('Download failed:', error);
    alert('Failed to fetch release information.');
  }
}

async function downloadLatestRelease(extension: string) {
  try {
    // Query GitHub's API for the latest release metadata
    const response = await fetch('https://api.github.com/repos/Abled-Taha/iron_book/releases/latest');
    const release = await response.json();

    // Find the asset matching the desired file format (.apk, .exe, etc.)
    const asset = release.assets?.find((a: { name: string }) => a.name.endsWith(extension));

    if (asset) {
      window.location.href = asset.browser_download_url;
    } else {
      alert(`Release file with extension "${extension}" not found.`);
    }
  } catch (error) {
    console.error('Download failed:', error);
    alert('Failed to fetch release information.');
  }
}

export default function Downloads() {
  const buttonStyle =
    'rounded-lg bg-zinc-900 px-4 py-2 text-sm font-semibold text-white transition hover:bg-zinc-700 dark:bg-zinc-100 dark:text-zinc-900 dark:hover:bg-zinc-300';

  return (
    <div className="min-h-screen bg-zinc-50 text-zinc-900 dark:bg-black dark:text-zinc-100">
      <div className="mx-auto flex max-w-7xl">
        {/* Main */}
        <main className="flex-1 px-6 py-16 sm:px-12 lg:px-20">
          <div className="mx-auto max-w-5xl space-y-24">
            {/* Hero */}
            <section className="space-y-6">
              <div className="inline-flex items-center rounded-full border border-zinc-300 bg-white px-3 py-1 text-xs font-medium dark:border-zinc-700 dark:bg-zinc-900">
                Downloads
              </div>

              <div className="space-y-3">
                <h1 className="text-5xl font-black tracking-tight">Project Iron Book</h1>

                <h2 className="text-xl text-zinc-600 dark:text-zinc-400">A Digital Financial Ledger</h2>
              </div>
            </section>

            {/* Linux */}
            <section id="linux" className="space-y-6 scroll-mt-24">
              <h2 className="text-3xl font-bold">Linux</h2>

              <div className="rounded-2xl border border-zinc-200 bg-white p-8 shadow-sm dark:border-zinc-800 dark:bg-zinc-900">
                <ul className="list-disc space-y-4 pl-6 leading-7 text-zinc-700 dark:text-zinc-300">
                  <li>Run this curl command.</li>
                  <p className="font-mono text-sm bg-zinc-100 dark:bg-zinc-800 p-2 rounded">
                    curl https://raw.githubusercontent.com/Abled-Taha/iron_book/refs/heads/main/scripts/linux_installer.sh | sh
                  </p>
                </ul>
              </div>
            </section>

            {/* Windows */}
            <section id="windows" className="space-y-6 scroll-mt-24">
              <h2 className="text-3xl font-bold">Windows</h2>

              <div className="rounded-2xl border border-zinc-200 bg-white p-8 shadow-sm dark:border-zinc-800 dark:bg-zinc-900">
                <div className="space-y-4 text-zinc-700 dark:text-zinc-300">
                  <p>Download and run the installer for the latest release.</p>
                  <div className="flex gap-4">
                    <button className={buttonStyle} onClick={() => downloadLatestRelease('.exe')}>
                      Stable Release (.exe)
                    </button>
                    <button className={buttonStyle} onClick={() => downloadLatestPreRelease('.exe')}>
                      Pre-Release (.exe)
                    </button>
                  </div>
                </div>
              </div>
            </section>

            {/* Android */}
            <section id="android" className="space-y-6 scroll-mt-24">
              <h2 className="text-3xl font-bold">Android</h2>

              <div className="rounded-2xl border border-zinc-200 bg-white p-8 shadow-sm dark:border-zinc-800 dark:bg-zinc-900">
                <div className="space-y-4 text-zinc-700 dark:text-zinc-300">
                  <p>Download and install the APK for the latest release.</p>
                  <div className="flex gap-4">
                    <button className={buttonStyle} onClick={() => downloadLatestRelease('.apk')}>
                      Stable Release (.apk)
                    </button>
                    <button className={buttonStyle} onClick={() => downloadLatestPreRelease('.apk')}>
                      Pre-Release (.apk)
                    </button>
                  </div>
                </div>
              </div>
            </section>
          </div>
        </main>
      </div>
    </div>
  );
}
