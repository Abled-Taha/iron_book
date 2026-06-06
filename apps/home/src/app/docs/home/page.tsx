export default function DocsHome() {
  return (
    <div className="min-h-screen bg-zinc-50 text-zinc-900 dark:bg-black dark:text-zinc-100">
      <div className="mx-auto flex max-w-7xl">
        {/* Main */}
        <main className="flex-1 px-6 py-16 sm:px-12 lg:px-20">
          <div className="mx-auto max-w-5xl space-y-24">
            {/* Hero */}
            <section className="space-y-6">
              <div className="inline-flex items-center rounded-full border border-zinc-300 bg-white px-3 py-1 text-xs font-medium dark:border-zinc-700 dark:bg-zinc-900">
                Documentation
              </div>

              <div className="space-y-3">
                <h1 className="text-5xl font-black tracking-tight">
                  Project Iron Book
                </h1>

                <h2 className="text-xl text-zinc-600 dark:text-zinc-400">
                  A Digital Financial Ledger
                </h2>
              </div>
            </section>

            {/* Setup Instructions */}
            <section
              id="setup-instructions"
              className="space-y-6 scroll-mt-24"
            >
              <h2 className="text-3xl font-bold">Setup Instructions</h2>

              <div className="rounded-2xl border border-zinc-200 bg-white p-8 shadow-sm dark:border-zinc-800 dark:bg-zinc-900">
                <h3 className="text-2xl font-bold">Docker Setup (Recommended)</h3>
                <ul className="list-disc space-y-4 pl-6 leading-7 text-zinc-700 dark:text-zinc-300">
                  <li>
                    File which can be used to deploy is
                    <pre className="min-w-max text-sm leading-6 text-zinc-100 ">`docker-compose.yaml`</pre>
                    <pre className="min-w-max text-sm leading-6 text-zinc-100 ">`docker compose up -d ironbook_db`</pre>
                  </li>

                  <li>
                    Required environment variables are
                    <pre className="min-w-max text-sm leading-6 text-zinc-100 ">`HOST_PORT`</pre>
                    <pre className="min-w-max text-sm leading-6 text-zinc-100 ">`NEXT_PUBLIC_SITE_URL`</pre>
                  </li>
                </ul>
              </div>

              <div className="rounded-2xl border border-zinc-200 bg-white p-8 shadow-sm dark:border-zinc-800 dark:bg-zinc-900">
                <h3 className="text-2xl font-bold">Direct From Repo</h3>
                <ul className="list-disc space-y-4 pl-6 leading-7 text-zinc-700 dark:text-zinc-300">
                  <li>
                    <a href="https://mise.jdx.dev">Mise</a> & <a href="https://docs.docker.com/desktop/setup/install/linux/">Docker Suite</a> must be installed
                  </li>

                  <li>
                    Clone <a href="https://github.com/Abled-Taha/iron_book">Git Repo</a>
                  </li>

                  <li>
                    To setup, run (in project directory)
                    <pre className="min-w-max text-sm leading-6 text-zinc-100 ">`mise trust; ./setup.sh`</pre>
                  </li>

                  <li>
                    To start the server, run (in project directory)
                    <pre className="min-w-max text-sm leading-6 text-zinc-100 ">`mise run prod:home`</pre>
                  </li>
                </ul>
              </div>
            </section>
          </div>
        </main>
      </div>
    </div>
  );
}
