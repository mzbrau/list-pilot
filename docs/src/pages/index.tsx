import clsx from 'clsx';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import useBaseUrl from '@docusaurus/useBaseUrl';
import Layout from '@theme/Layout';

const RELEASES_URL = 'https://github.com/mzbrau/list-pilot/releases/latest';

function DownloadButtons({className}: {className?: string}) {
  return (
    <div className={clsx('lp-hero__actions', className)}>
      <a className="lp-btn lp-btn--primary" href={RELEASES_URL}>
        <span aria-hidden>⬇</span> Download for Android
      </a>
      <span className="lp-btn lp-btn--disabled" aria-disabled="true">
        Google Play
        <span className="lp-badge">Coming soon</span>
      </span>
    </div>
  );
}

function FeatureCard({
  icon,
  title,
  description,
  iconBg,
}: {
  icon: string;
  title: string;
  description: string;
  iconBg?: string;
}) {
  return (
    <div className="lp-feature-card">
      <div
        className="lp-feature-card__icon"
        style={iconBg ? {background: iconBg} : undefined}>
        {icon}
      </div>
      <h3>{title}</h3>
      <p>{description}</p>
    </div>
  );
}

export default function Home(): JSX.Element {
  const {siteConfig} = useDocusaurusContext();
  const screenshotLight = useBaseUrl('/img/screenshot-list-light.png');
  const screenshotDark = useBaseUrl('/img/screenshot-list-dark.png');
  const screenshotCatalog = useBaseUrl('/img/screenshot-catalog-search.png');
  const listsPlaceholder = useBaseUrl('/img/lists-overview-placeholder.svg');

  return (
    <Layout
      title="List Pilot — Smart shopping list app"
      description="List Pilot organizes groceries by category and learns your check-off order for a faster shop.">
      <main className="lp-landing">
        <section className="lp-hero">
          <div className="lp-hero__grid">
            <div>
              <h1 className="lp-hero__headline">
                The Shopping List That <em>Learns</em> Your Store.
              </h1>
              <p className="lp-hero__tagline">
                Stop zig-zagging through aisles. {siteConfig.title} automatically
                organizes your groceries by category and learns your check-off
                order for a faster shop.
              </p>
              <DownloadButtons />
            </div>
            <div className="lp-screenshots">
              <div className="lp-screenshots__glow" aria-hidden />
              <div className="lp-phone">
                <img
                  src={screenshotLight}
                  alt="List Pilot shopping list in light mode"
                />
              </div>
              <div className="lp-phone">
                <img
                  src={screenshotDark}
                  alt="List Pilot shopping list in dark mode"
                />
              </div>
            </div>
          </div>
        </section>

        <section className="lp-section" id="features">
          <div className="lp-section__inner">
            <div className="lp-section__header">
              <h2 className="lp-section__title">Efficiency in your pocket</h2>
              <p className="lp-section__subtitle">
                Designed for busy households who want to get in and out of the
                store in record time.
              </p>
            </div>
            <div className="lp-features">
              <FeatureCard
                icon="↕"
                title="Smart ordering"
                description="List Pilot remembers the order you check items off and reorders future lists to match your walking path through the store."
              />
              <FeatureCard
                icon="▦"
                title="Category grouping"
                description="Items sort into Dairy, Produce, Meat, and more automatically — no more walking back for a forgotten onion."
                iconBg="rgba(117, 253, 0, 0.15)"
              />
              <FeatureCard
                icon="⚡"
                title="Fast entry"
                description="Predictive autocomplete and a built-in catalog of 370+ groceries make adding to your list instant."
                iconBg="rgba(0, 192, 149, 0.15)"
              />
            </div>
          </div>
        </section>

        <section className="lp-section lp-section--alt" id="how-it-works">
          <div className="lp-section__inner">
            <div className="lp-how-it-works">
              <div>
                <div className="lp-phone lp-phone--large">
                  <img
                    src={screenshotCatalog}
                    alt="Adding items with catalog autocomplete"
                  />
                </div>
              </div>
              <div>
                <h2 className="lp-section__title">3 steps to a faster shop</h2>
                <p className="lp-section__subtitle" style={{textAlign: 'left', margin: '0 0 2rem'}}>
                  List Pilot is built for utility — add items, shop naturally, and
                  let the app learn your route.
                </p>
                <div className="lp-steps">
                  <div className="lp-step">
                    <div className="lp-step__number">1</div>
                    <div>
                      <h4>Add items</h4>
                      <p>
                        Rapidly build your list with intelligent catalog
                        suggestions as you type.
                      </p>
                    </div>
                  </div>
                  <div className="lp-step">
                    <div className="lp-step__number">2</div>
                    <div>
                      <h4>Shop naturally</h4>
                      <p>
                        Check items off as you move through your favorite store.
                      </p>
                    </div>
                  </div>
                  <div className="lp-step">
                    <div className="lp-step__number">3</div>
                    <div>
                      <h4>Smart reorder</h4>
                      <p>
                        Next time, your list is sorted by the exact path you
                        walked.
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <figure className="lp-lists-preview">
              <img
                src={listsPlaceholder}
                alt="Placeholder for multiple lists overview screenshot"
              />
              <figcaption>Screenshot coming soon — manage separate lists for different stores</figcaption>
            </figure>
          </div>
        </section>

        <section className="lp-section" id="privacy">
          <div className="lp-section__inner lp-privacy">
            <div className="lp-privacy__badge">
              <span aria-hidden>🔒</span> Privacy first
            </div>
            <h2 className="lp-section__title">Your data stays yours</h2>
            <p className="lp-section__subtitle">
              List Pilot stores everything <strong>locally on your device</strong>.
              No cloud sync, no accounts, and no data mining — just a fast,
              dependable tool for daily shopping.
            </p>
            <div className="lp-privacy__icons">
              <div className="lp-privacy__icon-item">
                <span aria-hidden>💾</span>
                <span>Local storage</span>
              </div>
              <div className="lp-privacy__icon-item">
                <span aria-hidden>👤</span>
                <span>No sign-up</span>
              </div>
              <div className="lp-privacy__icon-item">
                <span aria-hidden>🛡</span>
                <span>Secure</span>
              </div>
            </div>
          </div>
        </section>

        <section className="lp-section">
          <div className="lp-section__inner">
            <div className="lp-cta">
              <div className="lp-cta__glow" aria-hidden />
              <h2>Ready to streamline your shopping?</h2>
              <p>
                Download List Pilot for Android from GitHub Releases. Google Play
                coming soon.
              </p>
              <DownloadButtons />
            </div>
          </div>
        </section>
      </main>
    </Layout>
  );
}
