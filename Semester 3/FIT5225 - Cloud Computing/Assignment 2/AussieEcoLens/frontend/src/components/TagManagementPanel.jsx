import { useMemo, useState } from 'react';

import {
  presignUrls,
  updateFileTags,
} from '../services/apiService';

const parseUrlsInput = (input) => {
  return input
    .split(/[\n,]+/)
    .map((item) => item.trim())
    .filter(Boolean);
};

const parseTagsInput = (input) => {
  return input
    .split(',')
    .map((item) => item.trim().toLowerCase())
    .filter(Boolean);
};

const cleanPreviewUrl = (url = '') => {
  return String(url || '').trim().split('?')[0];
};

function TagIcon() {
  return (
    <svg
      width="38"
      height="38"
      viewBox="0 0 24 24"
      fill="none"
      aria-hidden="true"
    >
      <path
        d="M4.75 5.75C4.75 5.19772 5.19772 4.75 5.75 4.75H12.7C13.2304 4.75 13.7391 4.96071 14.1142 5.33579L19.1642 10.3858C19.9453 11.1668 19.9453 12.4332 19.1642 13.2142L13.2142 19.1642C12.4332 19.9453 11.1668 19.9453 10.3858 19.1642L5.33579 14.1142C4.96071 13.7391 4.75 13.2304 4.75 12.7V5.75Z"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinejoin="round"
      />
      <path
        d="M8.75 8.75H8.762"
        stroke="currentColor"
        strokeWidth="2.6"
        strokeLinecap="round"
      />
    </svg>
  );
}

function TagManagementPanel() {
  const [operation, setOperation] = useState('add');
  const [urlsInput, setUrlsInput] = useState('');
  const [tagsInput, setTagsInput] = useState('');
  const [signedUrlMap, setSignedUrlMap] = useState({});
  const [rawResponse, setRawResponse] = useState(null);
  const [loading, setLoading] = useState(false);
  const [previewLoading, setPreviewLoading] = useState(false);
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');

  const parsedUrls = useMemo(() => parseUrlsInput(urlsInput), [urlsInput]);
  const parsedTags = useMemo(() => parseTagsInput(tagsInput), [tagsInput]);

  const resetOutput = () => {
    setRawResponse(null);
    setMessage('');
    setError('');
  };

  const handlePresignPreview = async () => {
    resetOutput();

    if (parsedUrls.length === 0) {
      setError('Please enter at least one file URL before preparing preview links.');
      return;
    }

    setPreviewLoading(true);

    try {
      const signedUrls = await presignUrls(parsedUrls);
      setSignedUrlMap(signedUrls);
      setMessage('Preview links are ready. Backend actions will still use the original raw URLs.');
    } catch (presignError) {
      setError(
        presignError.message ||
          'Could not create preview links. Please check the URLs.'
      );
    } finally {
      setPreviewLoading(false);
    }
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    resetOutput();

    if (parsedUrls.length === 0) {
      setError('Please enter at least one file URL.');
      return;
    }

    if (parsedTags.length === 0) {
      setError('Please enter at least one tag.');
      return;
    }

    setLoading(true);

    try {
      const signedUrls = await presignUrls(parsedUrls);
      setSignedUrlMap(signedUrls);

      const response = await updateFileTags({
        urls: parsedUrls,
        tags: parsedTags,
        operation,
      });

      setRawResponse(response);
      setMessage(
        `Tags ${operation === 'add' ? 'added to' : 'removed from'} ${
          parsedUrls.length
        } file(s).`
      );
    } catch (tagError) {
      setError(tagError.message || 'Tag update failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleClear = () => {
    setUrlsInput('');
    setTagsInput('');
    setSignedUrlMap({});
    setRawResponse(null);
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
              color: '#2d6a4f',
              fontSize: '13px',
              fontWeight: 900,
              letterSpacing: '0.08em',
              textTransform: 'uppercase',
            }}
          >
            Tag management
          </p>

          <h2
            style={{
              margin: '10px 0 10px',
              color: '#081c15',
              fontSize: '32px',
              letterSpacing: '-0.04em',
            }}
          >
            Add or remove file tags
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
            Enter the original file URLs or thumbnail URLs and the species tags
            to update. The backend action uses the stored media URL, while any
            clickable preview links are converted to short-lived presigned URLs.
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
                marginBottom: '20px',
              }}
            >
              <button
                type="button"
                onClick={() => setOperation('add')}
                style={{
                  border:
                    operation === 'add'
                      ? '1px solid #1b4332'
                      : '1px solid #d7e4dc',
                  background:
                    operation === 'add'
                      ? 'linear-gradient(135deg, #1b4332, #2d6a4f)'
                      : '#f8fcf9',
                  color: operation === 'add' ? '#ffffff' : '#1b4332',
                  borderRadius: '18px',
                  padding: '15px 16px',
                  fontSize: '15px',
                  fontWeight: 900,
                  cursor: 'pointer',
                  boxShadow:
                    operation === 'add'
                      ? '0 14px 30px rgba(27, 67, 50, 0.2)'
                      : 'none',
                }}
              >
                Add tags
              </button>

              <button
                type="button"
                onClick={() => setOperation('remove')}
                style={{
                  border:
                    operation === 'remove'
                      ? '1px solid #1b4332'
                      : '1px solid #d7e4dc',
                  background:
                    operation === 'remove'
                      ? 'linear-gradient(135deg, #1b4332, #2d6a4f)'
                      : '#f8fcf9',
                  color: operation === 'remove' ? '#ffffff' : '#1b4332',
                  borderRadius: '18px',
                  padding: '15px 16px',
                  fontSize: '15px',
                  fontWeight: 900,
                  cursor: 'pointer',
                  boxShadow:
                    operation === 'remove'
                      ? '0 14px 30px rgba(27, 67, 50, 0.2)'
                      : 'none',
                }}
              >
                Remove tags
              </button>
            </div>

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
                  resetOutput();
                }}
                placeholder="Paste one or more file URLs or thumbnail URLs. Use a new line or comma between URLs."
                rows={6}
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

            <label style={{ display: 'block', marginTop: '18px' }}>
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
                Tags
              </span>

              <input
                type="text"
                value={tagsInput}
                onChange={(event) => {
                  setTagsInput(event.target.value);
                  resetOutput();
                }}
                placeholder="Example: cat, bird, wombat"
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
              Tags are comma-separated. Do not paste already opened presigned
              URLs for tag updates.
            </p>

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
                    ? '#9fb8a8'
                    : 'linear-gradient(135deg, #1b4332, #2d6a4f)',
                  color: '#ffffff',
                  fontSize: '16px',
                  fontWeight: 900,
                  cursor: loading ? 'not-allowed' : 'pointer',
                  boxShadow: loading
                    ? 'none'
                    : '0 16px 35px rgba(27, 67, 50, 0.24)',
                }}
              >
                {loading
                  ? 'Updating tags...'
                  : operation === 'add'
                    ? 'Add tags'
                    : 'Remove tags'}
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
              color: '#95d5b2',
              fontSize: '12px',
              fontWeight: 900,
              letterSpacing: '0.08em',
              textTransform: 'uppercase',
            }}
          >
            Tag update summary
          </p>

          <div
            style={{
              marginTop: '16px',
              width: '82px',
              height: '82px',
              borderRadius: '28px',
              background: 'rgba(216, 243, 220, 0.12)',
              color: '#b7e4c7',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <TagIcon />
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
                Operation
              </p>

              <p
                style={{
                  margin: '6px 0 0',
                  color: '#ffffff',
                  fontSize: '15px',
                  fontWeight: 800,
                  textTransform: 'capitalize',
                }}
              >
                {operation} tags
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
                Tags entered
              </p>

              <p
                style={{
                  margin: '6px 0 0',
                  color: '#ffffff',
                  fontSize: '15px',
                  fontWeight: 800,
                  lineHeight: 1.45,
                  overflowWrap: 'break-word',
                }}
              >
                {parsedTags.length > 0 ? parsedTags.join(', ') : 'No tags'}
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

export default TagManagementPanel;