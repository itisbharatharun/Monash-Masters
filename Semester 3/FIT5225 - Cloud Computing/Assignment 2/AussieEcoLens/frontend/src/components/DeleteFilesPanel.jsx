import { useMemo, useState } from 'react';

import {
  deleteFiles,
  presignUrls,
} from '../services/apiService';

const parseUrlsInput = (input) => {
  return [
    ...new Set(
      input
        .split(/[\n,]+/)
        .map((item) => item.trim())
        .filter(Boolean)
    ),
  ];
};

const cleanPreviewUrl = (url = '') => {
  return String(url || '').trim().split('?')[0];
};

function DeleteIcon() {
  return (
    <svg
      width="38"
      height="38"
      viewBox="0 0 24 24"
      fill="none"
      aria-hidden="true"
    >
      <path
        d="M8.75 9.75V17.25"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
      />
      <path
        d="M12 9.75V17.25"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
      />
      <path
        d="M15.25 9.75V17.25"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
      />
      <path
        d="M4.75 6.75H19.25"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
      />
      <path
        d="M9.75 6.75V5.75C9.75 5.19772 10.1977 4.75 10.75 4.75H13.25C13.8023 4.75 14.25 5.19772 14.25 5.75V6.75"
        stroke="currentColor"
        strokeWidth="1.8"
      />
      <path
        d="M6.75 6.75L7.45 18.25C7.51368 19.2953 8.38009 20.1094 9.42731 20.1094H14.5727C15.6199 20.1094 16.4863 19.2953 16.55 18.25L17.25 6.75"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function DeleteFilesPanel() {
  const [urlsInput, setUrlsInput] = useState('');
  const [signedUrlMap, setSignedUrlMap] = useState({});
  const [rawResponse, setRawResponse] = useState(null);
  const [confirmed, setConfirmed] = useState(false);
  const [loading, setLoading] = useState(false);
  const [previewLoading, setPreviewLoading] = useState(false);
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');

  const parsedUrls = useMemo(() => parseUrlsInput(urlsInput), [urlsInput]);

  const resetOutput = () => {
    setRawResponse(null);
    setMessage('');
    setError('');
  };

  const handlePresignPreview = async () => {
    resetOutput();

    if (parsedUrls.length === 0) {
      setError('Please enter at least one file URL or thumbnail URL before preparing preview links.');
      return;
    }

    setPreviewLoading(true);

    try {
      const signedUrls = await presignUrls(parsedUrls);
      setSignedUrlMap(signedUrls);
      setMessage('Preview links are ready. The delete request will still use the stored media URLs.');
    } catch (presignError) {
      setError(
        presignError.message ||
          'Could not create preview links. Please check the URLs.'
      );
    } finally {
      setPreviewLoading(false);
    }
  };

  const handleDelete = async (event) => {
    event.preventDefault();
    resetOutput();

    if (parsedUrls.length === 0) {
      setError('Please enter at least one file URL or thumbnail URL.');
      return;
    }

    if (!confirmed) {
      setError('Please confirm that you want to delete the selected file(s).');
      return;
    }

    setLoading(true);

    try {
      const signedUrls = await presignUrls(parsedUrls);
      setSignedUrlMap(signedUrls);

      const response = await deleteFiles(parsedUrls);

      setRawResponse(response);
      setMessage(
        `Delete request completed for ${parsedUrls.length} file(s).`
      );
      setConfirmed(false);
    } catch (deleteError) {
      setError(deleteError.message || 'Delete request failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleClear = () => {
    setUrlsInput('');
    setSignedUrlMap({});
    setRawResponse(null);
    setConfirmed(false);
    setMessage('');
    setError('');
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
              color: '#9f1239',
              fontSize: '13px',
              fontWeight: 900,
              letterSpacing: '0.08em',
              textTransform: 'uppercase',
            }}
          >
            Delete files
          </p>

          <h2
            style={{
              margin: '10px 0 10px',
              color: '#081c15',
              fontSize: '32px',
              letterSpacing: '-0.04em',
            }}
          >
            Remove media and metadata
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
            Paste the original file URLs or thumbnail URLs to delete files from
            storage and remove the corresponding metadata records. Private media
            links are only presigned for preview.
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

          <form onSubmit={handleDelete} style={{ marginTop: '24px' }}>
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
                File URLs or thumbnail URLs
              </span>

              <textarea
                value={urlsInput}
                onChange={(event) => {
                  setUrlsInput(event.target.value);
                  setSignedUrlMap({});
                  setConfirmed(false);
                  resetOutput();
                }}
                placeholder="Paste one or more file URLs or thumbnail URLs. Use a new line or comma between URLs."
                rows={7}
                style={{
                  width: '100%',
                  resize: 'vertical',
                  border: '1px solid #d7e4dc',
                  borderRadius: '18px',
                  padding: '16px',
                  fontSize: '15px',
                  lineHeight: 1.55,
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
              You can paste a raw file URL or thumbnail URL. Do not paste
              already opened presigned URLs into this delete form.
            </p>

            <label
              style={{
                marginTop: '18px',
                display: 'flex',
                alignItems: 'flex-start',
                gap: '12px',
                padding: '16px',
                borderRadius: '18px',
                background: '#fff7ed',
                border: '1px solid #fed7aa',
                color: '#9a3412',
                cursor: 'pointer',
              }}
            >
              <input
                type="checkbox"
                checked={confirmed}
                onChange={(event) => setConfirmed(event.target.checked)}
                style={{
                  marginTop: '3px',
                  width: '18px',
                  height: '18px',
                  accentColor: '#9f1239',
                  flexShrink: 0,
                }}
              />

              <span
                style={{
                  fontSize: '14px',
                  lineHeight: 1.5,
                  fontWeight: 800,
                }}
              >
                I understand this will delete the selected media file(s),
                thumbnails, and metadata records from the system.
              </span>
            </label>

            <div
              style={{
                display: 'grid',
                gridTemplateColumns: '1fr auto auto',
                gap: '12px',
                marginTop: '18px',
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
                    ? '#d8a3ad'
                    : 'linear-gradient(135deg, #9f1239, #be123c)',
                  color: '#ffffff',
                  fontSize: '16px',
                  fontWeight: 900,
                  cursor: loading ? 'not-allowed' : 'pointer',
                  boxShadow: loading
                    ? 'none'
                    : '0 16px 35px rgba(159, 18, 57, 0.22)',
                }}
              >
                {loading ? 'Deleting...' : 'Delete selected files'}
              </button>

              <button
                type="button"
                onClick={handlePresignPreview}
                disabled={previewLoading}
                style={{
                  border: '1px solid #d7e4dc',
                  background: '#ffffff',
                  color: '#1b4332',
                  borderRadius: '18px',
                  padding: '16px 18px',
                  fontSize: '15px',
                  fontWeight: 900,
                  cursor: previewLoading ? 'not-allowed' : 'pointer',
                }}
              >
                {previewLoading ? 'Preparing...' : 'Preview links'}
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
              'linear-gradient(145deg, rgba(8, 28, 21, 0.96), rgba(27, 67, 50, 0.94))',
            padding: '22px',
            color: '#ffffff',
            minHeight: '390px',
            display: 'flex',
            flexDirection: 'column',
            boxShadow: '0 20px 50px rgba(8, 28, 21, 0.16)',
          }}
        >
          <p
            style={{
              margin: 0,
              color: '#fda4af',
              fontSize: '12px',
              fontWeight: 900,
              letterSpacing: '0.08em',
              textTransform: 'uppercase',
            }}
          >
            Delete summary
          </p>

          <div
            style={{
              marginTop: '16px',
              width: '82px',
              height: '82px',
              borderRadius: '28px',
              background: 'rgba(253, 164, 175, 0.12)',
              color: '#fda4af',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <DeleteIcon />
          </div>

          <div
            style={{
              display: 'grid',
              gap: '12px',
              marginTop: '20px',
            }}
          >
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
                Files selected
              </p>

              <p
                style={{
                  margin: '6px 0 0',
                  color: '#ffffff',
                  fontSize: '15px',
                  fontWeight: 800,
                }}
              >
                {parsedUrls.length} file(s)
              </p>
            </div>

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
                Confirmation
              </p>

              <p
                style={{
                  margin: '6px 0 0',
                  color: confirmed ? '#b7e4c7' : '#fda4af',
                  fontSize: '15px',
                  fontWeight: 800,
                }}
              >
                {confirmed ? 'Confirmed' : 'Not confirmed'}
              </p>
            </div>

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
                Backend input
              </p>

              <p
                style={{
                  margin: '6px 0 0',
                  color: '#ffffff',
                  fontSize: '14px',
                  lineHeight: 1.5,
                  fontWeight: 700,
                }}
              >
                The frontend resolves thumbnail URLs before sending delete
                requests. Presigned URLs are only used for safe preview links.
              </p>
            </div>

            {parsedUrls.length > 0 && (
              <details
                style={{
                  padding: '14px',
                  borderRadius: '18px',
                  background: 'rgba(255, 255, 255, 0.08)',
                  border: '1px solid rgba(216, 243, 220, 0.14)',
                }}
              >
                <summary
                  style={{
                    cursor: 'pointer',
                    color: '#95d5b2',
                    fontSize: '12px',
                    fontWeight: 900,
                    textTransform: 'uppercase',
                    letterSpacing: '0.08em',
                  }}
                >
                  File preview links
                </summary>

                {parsedUrls.map((rawUrl, index) => {
                  const cleanedUrl = cleanPreviewUrl(rawUrl);
                  const signedUrl =
                    signedUrlMap[rawUrl] || signedUrlMap[cleanedUrl];

                  if (!signedUrl) {
                    return (
                      <p
                        key={`${rawUrl}-${index}`}
                        style={{
                          margin: '10px 0 0',
                          color: '#95d5b2',
                          fontSize: '12px',
                          lineHeight: 1.5,
                          overflowWrap: 'break-word',
                          fontWeight: 700,
                          fontStyle: 'italic',
                        }}
                      >
                        {rawUrl} — click Preview links to activate
                      </p>
                    );
                  }

                  return (
                    <a
                      key={`${rawUrl}-${index}`}
                      href={signedUrl}
                      target="_blank"
                      rel="noreferrer"
                      style={{
                        display: 'block',
                        marginTop: '10px',
                        color: '#ffffff',
                        fontSize: '12px',
                        lineHeight: 1.5,
                        overflowWrap: 'break-word',
                        fontWeight: 700,
                      }}
                    >
                      {rawUrl}
                    </a>
                  );
                })}
              </details>
            )}
          </div>
        </aside>
      </div>
    </section>
  );
}

export default DeleteFilesPanel;