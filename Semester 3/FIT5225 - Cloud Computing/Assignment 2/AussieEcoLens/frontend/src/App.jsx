import { useEffect, useState } from 'react';

import DeleteFilesPanel from './components/DeleteFilesPanel';
import NotificationsPanel from './components/NotificationsPanel';
import QueryPanel from './components/QueryPanel';
import ReverseSearchPanel from './components/ReverseSearchPanel';
import TagManagementPanel from './components/TagManagementPanel';
import ThumbnailLookupPanel from './components/ThumbnailLookupPanel';
import UploadPanel from './components/UploadPanel';
import AuthPage from './pages/AuthPage';
import { getLoggedInUser, logoutUser } from './services/authService';

function LoadingScreen() {
  return (
    <main
      style={{
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        background: '#eef7f0',
        color: '#1b4332',
        fontFamily:
          'Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif',
        fontWeight: 800,
        fontSize: '20px',
      }}
    >
      Loading AussieEcoLens...
    </main>
  );
}

const dashboardSections = [
  {
    id: 'upload',
    label: 'Upload Media',
    icon: '⬆️',
    eyebrow: 'Media ingestion',
    title: 'Upload wildlife images and videos',
    description:
      'Upload media securely through the GCP proxy and presigned S3 upload flow.',
    component: <UploadPanel />,
  },
  {
    id: 'query',
    label: 'Search Library',
    icon: '🔍',
    eyebrow: 'Media discovery',
    title: 'Search wildlife records',
    description:
      'Find stored images and videos by species or by tag counts using protected backend queries.',
    component: <QueryPanel />,
  },
  {
    id: 'thumbnail',
    label: 'Thumbnail Lookup',
    icon: '🖼️',
    eyebrow: 'Media mapping',
    title: 'Map thumbnail URLs to full media',
    description:
      'Paste an image or video thumbnail URL and retrieve the corresponding full-size media URL.',
    component: <ThumbnailLookupPanel />,
  },
  {
    id: 'reverse',
    label: 'Reverse Search',
    icon: '🧠',
    eyebrow: 'ML-assisted search',
    title: 'Search using an uploaded image',
    description:
      'Upload a query image and find matching database files based on detected species tags.',
    component: <ReverseSearchPanel />,
  },
  {
    id: 'tags',
    label: 'Manage Tags',
    icon: '🏷️',
    eyebrow: 'Metadata management',
    title: 'Add or remove tags in bulk',
    description:
      'Manually update file metadata by adding or removing common-name species tags.',
    component: <TagManagementPanel />,
  },
  {
    id: 'delete',
    label: 'Delete Files',
    icon: '🗑️',
    eyebrow: 'Data management',
    title: 'Delete files and metadata',
    description:
      'Remove selected files, thumbnails, and database records through the protected delete endpoint.',
    component: <DeleteFilesPanel />,
  },
  {
    id: 'notifications',
    label: 'Notifications',
    icon: '📧',
    eyebrow: 'Species alerts',
    title: 'Subscribe to species email alerts',
    description:
      'Manage SNS-based email notifications for specific watched wildlife species.',
    component: <NotificationsPanel />,
  },
];

function StatCard({ label, value }) {
  return (
    <div
      style={{
        background: 'rgba(255, 255, 255, 0.78)',
        border: '1px solid rgba(216, 226, 220, 0.9)',
        borderRadius: '18px',
        padding: '18px',
        boxShadow: '0 12px 30px rgba(8, 28, 21, 0.06)',
      }}
    >
      <p
        style={{
          margin: 0,
          color: '#607166',
          fontSize: '13px',
          fontWeight: 800,
          textTransform: 'uppercase',
          letterSpacing: '0.06em',
        }}
      >
        {label}
      </p>

      <p
        style={{
          margin: '8px 0 0',
          color: '#081c15',
          fontSize: '24px',
          fontWeight: 900,
        }}
      >
        {value}
      </p>
    </div>
  );
}

function DashboardShell({ user, onSignOut }) {
  const [activeSection, setActiveSection] = useState('upload');

  const displayName =
    user?.signInDetails?.loginId || user?.username || 'Authenticated user';

  const selectedSection =
    dashboardSections.find((section) => section.id === activeSection) ||
    dashboardSections[0];

  return (
    <main
      style={{
        minHeight: '100vh',
        background:
          'radial-gradient(circle at top left, #d8f3dc 0, transparent 30%), linear-gradient(135deg, #f7fbf8 0%, #eef7f0 45%, #f4f8f5 100%)',
        color: '#1f2933',
        fontFamily:
          'Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif',
      }}
    >
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: '300px 1fr',
          minHeight: '100vh',
        }}
      >
        <aside
          style={{
            background: '#081c15',
            color: '#ffffff',
            padding: '28px 22px',
            display: 'flex',
            flexDirection: 'column',
            gap: '24px',
            position: 'sticky',
            top: 0,
            height: '100vh',
            overflowY: 'auto',
          }}
        >
          <div>
            <div
              style={{
                width: '54px',
                height: '54px',
                borderRadius: '18px',
                background: 'linear-gradient(135deg, #52b788, #b7e4c7)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: '26px',
                marginBottom: '16px',
              }}
            >
              🐾
            </div>

            <h1
              style={{
                margin: 0,
                fontSize: '28px',
                lineHeight: 1.1,
                letterSpacing: '-0.04em',
              }}
            >
              AussieEcoLens
            </h1>

            <p
              style={{
                margin: '10px 0 0',
                color: '#b7e4c7',
                lineHeight: 1.5,
                fontSize: '14px',
              }}
            >
              Multi-cloud wildlife observation dashboard
            </p>
          </div>

          <nav style={{ display: 'grid', gap: '8px' }}>
            {dashboardSections.map((section) => {
              const isActive = section.id === activeSection;

              return (
                <button
                  key={section.id}
                  type="button"
                  onClick={() => setActiveSection(section.id)}
                  style={{
                    border: 'none',
                    borderRadius: '16px',
                    padding: '14px 16px',
                    display: 'flex',
                    alignItems: 'center',
                    gap: '12px',
                    textAlign: 'left',
                    background: isActive
                      ? 'linear-gradient(135deg, #ffffff, #d8f3dc)'
                      : 'transparent',
                    color: isActive ? '#081c15' : '#d8f3dc',
                    fontWeight: 800,
                    cursor: 'pointer',
                    transition: 'all 0.2s ease',
                  }}
                >
                  <span style={{ fontSize: '18px' }}>{section.icon}</span>
                  <span>{section.label}</span>
                </button>
              );
            })}
          </nav>

          <div
            style={{
              marginTop: 'auto',
              padding: '16px',
              borderRadius: '18px',
              background: 'rgba(255, 255, 255, 0.08)',
              border: '1px solid rgba(216, 243, 220, 0.16)',
            }}
          >
            <p
              style={{
                margin: 0,
                color: '#95d5b2',
                fontSize: '12px',
                fontWeight: 900,
                textTransform: 'uppercase',
                letterSpacing: '0.08em',
              }}
            >
              Signed in
            </p>

            <p
              style={{
                margin: '8px 0 14px',
                color: '#ffffff',
                fontSize: '14px',
                lineHeight: 1.4,
                overflowWrap: 'break-word',
              }}
            >
              {displayName}
            </p>

            <button
              type="button"
              onClick={onSignOut}
              style={{
                width: '100%',
                border: '1px solid rgba(216, 243, 220, 0.35)',
                background: 'rgba(255, 255, 255, 0.08)',
                color: '#ffffff',
                padding: '12px 14px',
                borderRadius: '14px',
                fontWeight: 800,
                cursor: 'pointer',
              }}
            >
              Sign out
            </button>
          </div>
        </aside>

        <section
          style={{
            padding: '34px',
            overflowX: 'hidden',
          }}
        >
          <header
            style={{
              marginBottom: '28px',
              background:
                'linear-gradient(135deg, rgba(255,255,255,0.92), rgba(248,251,249,0.92))',
              border: '1px solid rgba(216, 226, 220, 0.9)',
              borderRadius: '30px',
              padding: '34px',
              boxShadow: '0 20px 60px rgba(8, 28, 21, 0.08)',
            }}
          >
            <p
              style={{
                margin: 0,
                color: '#2d6a4f',
                fontWeight: 900,
                letterSpacing: '0.08em',
                textTransform: 'uppercase',
                fontSize: '13px',
              }}
            >
              FIT5225 Assignment 2
            </p>

            <div
              style={{
                display: 'grid',
                gridTemplateColumns: '1fr auto',
                gap: '24px',
                alignItems: 'start',
              }}
            >
              <div>
                <h2
                  style={{
                    margin: '12px 0 12px',
                    fontSize: '44px',
                    lineHeight: 1.08,
                    color: '#081c15',
                    letterSpacing: '-0.05em',
                  }}
                >
                  Wildlife media management across AWS and GCP
                </h2>

                <p
                  style={{
                    color: '#52635a',
                    fontSize: '17px',
                    lineHeight: 1.7,
                    maxWidth: '820px',
                    margin: 0,
                  }}
                >
                  Upload, classify, search, manage, and receive notifications
                  for Australian wildlife media using a protected multi-cloud
                  serverless pipeline.
                </p>
              </div>

              <div
                style={{
                  background: '#1b4332',
                  color: '#ffffff',
                  borderRadius: '22px',
                  padding: '18px 20px',
                  minWidth: '190px',
                  boxShadow: '0 16px 35px rgba(27, 67, 50, 0.22)',
                }}
              >
                <p
                  style={{
                    margin: 0,
                    color: '#b7e4c7',
                    fontSize: '12px',
                    fontWeight: 900,
                    letterSpacing: '0.08em',
                    textTransform: 'uppercase',
                  }}
                >
                  Status
                </p>

                <p
                  style={{
                    margin: '8px 0 0',
                    fontWeight: 900,
                    fontSize: '20px',
                  }}
                >
                  Protected UI
                </p>
              </div>
            </div>

            <div
              style={{
                display: 'grid',
                gridTemplateColumns: 'repeat(3, minmax(0, 1fr))',
                gap: '16px',
                marginTop: '28px',
              }}
            >
              <StatCard label="Cloud providers" value="AWS + GCP" />
              <StatCard label="Frontend features" value="7 modules" />
              <StatCard label="Access control" value="Cognito JWT" />
            </div>
          </header>

          <div
            style={{
              marginBottom: '22px',
              background: '#ffffff',
              border: '1px solid #d9e2dc',
              borderRadius: '24px',
              padding: '26px 30px',
              boxShadow: '0 16px 45px rgba(8, 28, 21, 0.06)',
            }}
          >
            <p
              style={{
                margin: 0,
                color: '#2d6a4f',
                fontWeight: 900,
                textTransform: 'uppercase',
                letterSpacing: '0.08em',
                fontSize: '12px',
              }}
            >
              {selectedSection.eyebrow}
            </p>

            <h3
              style={{
                margin: '8px 0',
                color: '#081c15',
                fontSize: '30px',
                letterSpacing: '-0.03em',
              }}
            >
              {selectedSection.icon} {selectedSection.title}
            </h3>

            <p
              style={{
                margin: 0,
                color: '#607166',
                lineHeight: 1.6,
                fontSize: '16px',
              }}
            >
              {selectedSection.description}
            </p>
          </div>

          <div>{selectedSection.component}</div>
        </section>
      </div>
    </main>
  );
}

function App() {
  const [checkingAuth, setCheckingAuth] = useState(true);
  const [currentUser, setCurrentUser] = useState(null);

  useEffect(() => {
    let isMounted = true;

    async function checkAuthStatus() {
      try {
        const user = await getLoggedInUser();

        if (isMounted) {
          setCurrentUser(user);
        }
      } catch {
        if (isMounted) {
          setCurrentUser(null);
        }
      } finally {
        if (isMounted) {
          setCheckingAuth(false);
        }
      }
    }

    checkAuthStatus();

    return () => {
      isMounted = false;
    };
  }, []);

  const handleLoginSuccess = async () => {
    const user = await getLoggedInUser();
    setCurrentUser(user);
  };

  const handleSignOut = async () => {
    await logoutUser();
    setCurrentUser(null);
  };

  if (checkingAuth) {
    return <LoadingScreen />;
  }

  if (!currentUser) {
    return <AuthPage onLoginSuccess={handleLoginSuccess} />;
  }

  return <DashboardShell user={currentUser} onSignOut={handleSignOut} />;
}

export default App;