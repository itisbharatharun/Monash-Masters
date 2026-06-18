import { useMemo, useState } from 'react';

import {
  subscribeToNotifications,
  unsubscribeFromNotifications,
} from '../services/apiService';

const parseSpecies = (input) => {
  return input
    .split(',')
    .map((item) => item.trim().toLowerCase())
    .filter(Boolean);
};

function NotificationIcon() {
  return (
    <svg
      width="38"
      height="38"
      viewBox="0 0 24 24"
      fill="none"
      aria-hidden="true"
    >
      <path
        d="M5.75 8.75C5.75 6.67893 7.42893 5 9.5 5H14.5C16.5711 5 18.25 6.67893 18.25 8.75V13.25L20 16.75H4L5.75 13.25V8.75Z"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinejoin="round"
      />
      <path
        d="M9.75 18.25C10.1 19.25 10.95 20 12 20C13.05 20 13.9 19.25 14.25 18.25"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
      />
      <path
        d="M12 3.75V5"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
      />
    </svg>
  );
}

function NotificationsPanel() {
  const [mode, setMode] = useState('subscribe');
  const [email, setEmail] = useState('');
  const [speciesInput, setSpeciesInput] = useState('');
  const [loading, setLoading] = useState(false);
  const [rawResponse, setRawResponse] = useState(null);
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');

  const parsedSpecies = useMemo(() => parseSpecies(speciesInput), [speciesInput]);

  const resetOutput = () => {
    setRawResponse(null);
    setMessage('');
    setError('');
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    resetOutput();

    const cleanedEmail = email.trim();

    if (!cleanedEmail) {
      setError('Please enter an email address.');
      return;
    }

    if (!cleanedEmail.includes('@')) {
      setError('Please enter a valid email address.');
      return;
    }

    if (mode === 'subscribe' && parsedSpecies.length === 0) {
      setError('Please enter at least one species for notification alerts.');
      return;
    }

    setLoading(true);

    try {
      if (mode === 'subscribe') {
        const data = await subscribeToNotifications({
          email: cleanedEmail,
          species: parsedSpecies,
        });

        setRawResponse(data);
        setMessage(
          'Subscription request sent. Please check the email inbox and confirm the SNS subscription.'
        );
      } else {
        const data = await unsubscribeFromNotifications(cleanedEmail);

        setRawResponse(data);
        setMessage('Unsubscribe request completed.');
      }
    } catch (notificationError) {
      setError(
        notificationError.message ||
          `Failed to ${mode === 'subscribe' ? 'subscribe' : 'unsubscribe'}.`
      );
    } finally {
      setLoading(false);
    }
  };

  const handleClear = () => {
    setEmail('');
    setSpeciesInput('');
    setMode('subscribe');
    resetOutput();
  };

  return (
    <section
      style={{
        background: '#ffffff',
        border: '1px solid #d9e2dc',
        borderRadius: '28px',
        padding: '32px',
        boxShadow: '0 18px 50px rgba(8, 28, 21, 0.07)',
      }}
    >
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'minmax(0, 1fr) 340px',
          gap: '28px',
          alignItems: 'start',
        }}
      >
        <div>
          <p
            style={{
              margin: 0,
              color: '#2d6a4f',
              fontSize: '13px',
              fontWeight: 900,
              letterSpacing: '0.08em',
              textTransform: 'uppercase',
            }}
          >
            Species alerts
          </p>

          <h2
            style={{
              margin: '10px 0 10px',
              color: '#081c15',
              fontSize: '32px',
              letterSpacing: '-0.04em',
            }}
          >
            Manage email notifications
          </h2>

          <p
            style={{
              margin: 0,
              color: '#607166',
              fontSize: '16px',
              lineHeight: 1.65,
              maxWidth: '820px',
            }}
          >
            Subscribe an email address to receive alerts when selected wildlife
            species are detected by the backend pipeline. Subscriptions are
            managed through the protected notification endpoint and AWS SNS.
          </p>

          {(message || error) && (
            <div
              style={{
                marginTop: '22px',
                padding: '16px 18px',
                borderRadius: '18px',
                background: error ? '#fff1f2' : '#e9f8ee',
                border: error ? '1px solid #fecdd3' : '1px solid #b7e4c7',
                color: error ? '#9f1239' : '#1b4332',
                fontSize: '14px',
                fontWeight: 800,
                lineHeight: 1.5,
              }}
            >
              {error || message}
            </div>
          )}

          <form onSubmit={handleSubmit} style={{ marginTop: '24px' }}>
            <div
              style={{
                display: 'grid',
                gridTemplateColumns: 'repeat(2, minmax(0, 1fr))',
                gap: '12px',
                marginBottom: '22px',
              }}
            >
              <button
                type="button"
                onClick={() => {
                  setMode('subscribe');
                  resetOutput();
                }}
                style={{
                  border:
                    mode === 'subscribe'
                      ? '1px solid #1b4332'
                      : '1px solid #d7e4dc',
                  background:
                    mode === 'subscribe'
                      ? 'linear-gradient(135deg, #1b4332, #2d6a4f)'
                      : '#f8fcf9',
                  color: mode === 'subscribe' ? '#ffffff' : '#1b4332',
                  borderRadius: '18px',
                  padding: '15px 16px',
                  fontSize: '15px',
                  fontWeight: 900,
                  cursor: 'pointer',
                  boxShadow:
                    mode === 'subscribe'
                      ? '0 14px 30px rgba(27, 67, 50, 0.2)'
                      : 'none',
                }}
              >
                Subscribe
              </button>

              <button
                type="button"
                onClick={() => {
                  setMode('unsubscribe');
                  resetOutput();
                }}
                style={{
                  border:
                    mode === 'unsubscribe'
                      ? '1px solid #9b2226'
                      : '1px solid #d7e4dc',
                  background:
                    mode === 'unsubscribe'
                      ? 'linear-gradient(135deg, #7f1d1d, #9b2226)'
                      : '#f8fcf9',
                  color: mode === 'unsubscribe' ? '#ffffff' : '#1b4332',
                  borderRadius: '18px',
                  padding: '15px 16px',
                  fontSize: '15px',
                  fontWeight: 900,
                  cursor: 'pointer',
                  boxShadow:
                    mode === 'unsubscribe'
                      ? '0 14px 30px rgba(127, 29, 29, 0.2)'
                      : 'none',
                }}
              >
                Unsubscribe
              </button>
            </div>

            <label style={{ display: 'block', marginBottom: '18px' }}>
              <span
                style={{
                  display: 'block',
                  marginBottom: '8px',
                  color: '#1b4332',
                  fontSize: '13px',
                  fontWeight: 900,
                  letterSpacing: '0.05em',
                  textTransform: 'uppercase',
                }}
              >
                Email address
              </span>

              <input
                type="email"
                value={email}
                onChange={(event) => {
                  setEmail(event.target.value);
                  resetOutput();
                }}
                placeholder="name@example.com"
                style={{
                  width: '100%',
                  border: '1px solid #d7e4dc',
                  borderRadius: '18px',
                  padding: '15px 16px',
                  fontSize: '15px',
                  outline: 'none',
                  background: '#ffffff',
                  color: '#081c15',
                }}
              />
            </label>

            {mode === 'subscribe' && (
              <>
                <label style={{ display: 'block' }}>
                  <span
                    style={{
                      display: 'block',
                      marginBottom: '8px',
                      color: '#1b4332',
                      fontSize: '13px',
                      fontWeight: 900,
                      letterSpacing: '0.05em',
                      textTransform: 'uppercase',
                    }}
                  >
                    Species filters
                  </span>

                  <input
                    type="text"
                    value={speciesInput}
                    onChange={(event) => {
                      setSpeciesInput(event.target.value);
                      resetOutput();
                    }}
                    placeholder="Example: cat, wombat, dingo"
                    style={{
                      width: '100%',
                      border: '1px solid #d7e4dc',
                      borderRadius: '18px',
                      padding: '15px 16px',
                      fontSize: '15px',
                      outline: 'none',
                      background: '#ffffff',
                      color: '#081c15',
                    }}
                  />
                </label>

                <p
                  style={{
                    margin: '10px 0 0',
                    color: '#607166',
                    fontSize: '13px',
                    lineHeight: 1.5,
                  }}
                >
                  Use comma-separated common species tags such as
                  <strong> cat</strong>, <strong>wombat</strong>,{' '}
                  <strong>dingo</strong>, or <strong>kookaburra</strong>.
                </p>
              </>
            )}

            {mode === 'unsubscribe' && (
              <div
                style={{
                  padding: '16px',
                  borderRadius: '20px',
                  background: '#fff7ed',
                  border: '1px solid #fed7aa',
                  color: '#9a3412',
                  fontSize: '14px',
                  lineHeight: 1.55,
                  fontWeight: 800,
                }}
              >
                Unsubscribe mode only requires the email address. It will remove
                the email from existing notification subscriptions where
                supported by the backend.
              </div>
            )}

            <div
              style={{
                display: 'grid',
                gridTemplateColumns: '1fr auto',
                gap: '12px',
                marginTop: '20px',
              }}
            >
              <button
                type="submit"
                disabled={loading}
                style={{
                  border: 'none',
                  borderRadius: '18px',
                  padding: '16px 18px',
                  background: loading
                    ? '#9fb8a8'
                    : mode === 'subscribe'
                      ? 'linear-gradient(135deg, #1b4332, #2d6a4f)'
                      : 'linear-gradient(135deg, #7f1d1d, #9b2226)',
                  color: '#ffffff',
                  fontSize: '16px',
                  fontWeight: 900,
                  cursor: loading ? 'not-allowed' : 'pointer',
                  boxShadow: loading
                    ? 'none'
                    : mode === 'subscribe'
                      ? '0 16px 35px rgba(27, 67, 50, 0.24)'
                      : '0 16px 35px rgba(127, 29, 29, 0.22)',
                }}
              >
                {loading
                  ? 'Processing request...'
                  : mode === 'subscribe'
                    ? 'Subscribe to alerts'
                    : 'Unsubscribe email'}
              </button>

              <button
                type="button"
                onClick={handleClear}
                style={{
                  border: '1px solid #d7e4dc',
                  background: '#ffffff',
                  color: '#1b4332',
                  borderRadius: '18px',
                  padding: '16px 18px',
                  fontSize: '15px',
                  fontWeight: 900,
                  cursor: 'pointer',
                }}
              >
                Clear
              </button>
            </div>
          </form>

          {rawResponse && (
            <details
              style={{
                marginTop: '18px',
                borderRadius: '18px',
                background: '#f8fcf9',
                border: '1px solid #d7e9dd',
                padding: '14px',
              }}
            >
              <summary
                style={{
                  cursor: 'pointer',
                  color: '#2d6a4f',
                  fontSize: '13px',
                  fontWeight: 900,
                }}
              >
                View backend response
              </summary>

              <pre
                style={{
                  margin: '12px 0 0',
                  whiteSpace: 'pre-wrap',
                  overflowWrap: 'break-word',
                  color: '#607166',
                  fontSize: '12px',
                  lineHeight: 1.5,
                }}
              >
                {JSON.stringify(rawResponse, null, 2)}
              </pre>
            </details>
          )}
        </div>

        <aside
          style={{
            borderRadius: '26px',
            background:
              mode === 'subscribe'
                ? 'linear-gradient(145deg, rgba(8, 28, 21, 0.96), rgba(27, 67, 50, 0.94))'
                : 'linear-gradient(145deg, rgba(127, 29, 29, 0.96), rgba(155, 34, 38, 0.94))',
            padding: '22px',
            color: '#ffffff',
            minHeight: '390px',
            display: 'flex',
            flexDirection: 'column',
            boxShadow:
              mode === 'subscribe'
                ? '0 20px 50px rgba(8, 28, 21, 0.16)'
                : '0 20px 50px rgba(127, 29, 29, 0.16)',
          }}
        >
          <p
            style={{
              margin: 0,
              color: mode === 'subscribe' ? '#95d5b2' : '#fecaca',
              fontSize: '12px',
              fontWeight: 900,
              letterSpacing: '0.08em',
              textTransform: 'uppercase',
            }}
          >
            Notification summary
          </p>

          <div
            style={{
              marginTop: '16px',
              borderRadius: '22px',
              background: 'rgba(255, 255, 255, 0.08)',
              border:
                mode === 'subscribe'
                  ? '1px solid rgba(216, 243, 220, 0.18)'
                  : '1px solid rgba(254, 202, 202, 0.22)',
              minHeight: '210px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              textAlign: 'center',
              padding: '24px',
            }}
          >
            <div>
              <div
                style={{
                  width: '72px',
                  height: '72px',
                  margin: '0 auto 16px',
                  borderRadius: '24px',
                  background: 'rgba(255, 255, 255, 0.12)',
                  color: mode === 'subscribe' ? '#b7e4c7' : '#fecaca',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                }}
              >
                <NotificationIcon />
              </div>

              <p
                style={{
                  margin: 0,
                  color: mode === 'subscribe' ? '#d8f3dc' : '#fee2e2',
                  fontSize: '15px',
                  lineHeight: 1.6,
                  fontWeight: 700,
                }}
              >
                {mode === 'subscribe'
                  ? 'Subscribe users to species-specific email alerts using SNS.'
                  : 'Remove an email address from notification subscriptions.'}
              </p>
            </div>
          </div>

          <div
            style={{
              marginTop: '18px',
              display: 'grid',
              gap: '12px',
            }}
          >
            <div
              style={{
                padding: '14px',
                borderRadius: '18px',
                background: 'rgba(255, 255, 255, 0.08)',
                border:
                  mode === 'subscribe'
                    ? '1px solid rgba(216, 243, 220, 0.14)'
                    : '1px solid rgba(254, 202, 202, 0.18)',
              }}
            >
              <p
                style={{
                  margin: 0,
                  color: mode === 'subscribe' ? '#95d5b2' : '#fecaca',
                  fontSize: '12px',
                  fontWeight: 900,
                  textTransform: 'uppercase',
                  letterSpacing: '0.08em',
                }}
              >
                Selected mode
              </p>

              <p
                style={{
                  margin: '6px 0 0',
                  color: '#ffffff',
                  fontSize: '15px',
                  fontWeight: 800,
                }}
              >
                {mode === 'subscribe' ? 'Subscribe' : 'Unsubscribe'}
              </p>
            </div>

            <div
              style={{
                padding: '14px',
                borderRadius: '18px',
                background: 'rgba(255, 255, 255, 0.08)',
                border:
                  mode === 'subscribe'
                    ? '1px solid rgba(216, 243, 220, 0.14)'
                    : '1px solid rgba(254, 202, 202, 0.18)',
              }}
            >
              <p
                style={{
                  margin: 0,
                  color: mode === 'subscribe' ? '#95d5b2' : '#fecaca',
                  fontSize: '12px',
                  fontWeight: 900,
                  textTransform: 'uppercase',
                  letterSpacing: '0.08em',
                }}
              >
                Email
              </p>

              <p
                style={{
                  margin: '6px 0 0',
                  color: '#ffffff',
                  fontSize: '14px',
                  lineHeight: 1.5,
                  fontWeight: 800,
                  overflowWrap: 'break-word',
                }}
              >
                {email.trim() || 'No email entered'}
              </p>
            </div>

            {mode === 'subscribe' && (
              <div
                style={{
                  padding: '14px',
                  borderRadius: '18px',
                  background: 'rgba(255, 255, 255, 0.08)',
                  border: '1px solid rgba(216, 243, 220, 0.14)',
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
                  Species filters
                </p>

                <p
                  style={{
                    margin: '6px 0 0',
                    color: '#ffffff',
                    fontSize: '14px',
                    lineHeight: 1.5,
                    fontWeight: 800,
                    overflowWrap: 'break-word',
                  }}
                >
                  {parsedSpecies.length > 0
                    ? parsedSpecies.join(', ')
                    : 'No species selected'}
                </p>
              </div>
            )}

            <div
              style={{
                padding: '14px',
                borderRadius: '18px',
                background: 'rgba(255, 255, 255, 0.08)',
                border:
                  mode === 'subscribe'
                    ? '1px solid rgba(216, 243, 220, 0.14)'
                    : '1px solid rgba(254, 202, 202, 0.18)',
              }}
            >
              <p
                style={{
                  margin: 0,
                  color: mode === 'subscribe' ? '#95d5b2' : '#fecaca',
                  fontSize: '12px',
                  fontWeight: 900,
                  textTransform: 'uppercase',
                  letterSpacing: '0.08em',
                }}
              >
                Important
              </p>

              <p
                style={{
                  margin: '6px 0 0',
                  color: '#ffffff',
                  fontSize: '14px',
                  lineHeight: 1.5,
                  fontWeight: 800,
                }}
              >
                SNS subscription emails must be confirmed before alerts are
                delivered.
              </p>
            </div>
          </div>
        </aside>
      </div>
    </section>
  );
}

export default NotificationsPanel;