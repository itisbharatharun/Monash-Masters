import { useState } from 'react';

import {
  getDisplayUrl,
  getUniqueHttpUrls,
  presignUrls,
  queryByThumbnailUrl,
} from '../services/apiService';

const videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm', '.wmv', '.flv'];

const getFullMediaUrl = (data) => {
  if (!data) {
    return '';
  }

  return (
    data.file_url ||
    data.url ||
    data.full_image_url ||
    data.full_size_url ||
    data.full_media_url ||
    data.media_url ||
    data.video_url ||
    data.result?.file_url ||
    data.result?.url ||
    data.result?.media_url ||
    data.result?.video_url ||
    ''
  );
};

const getFileExtensionFromUrl = (url = '') => {
  const cleanUrl = url.split('?')[0];
  const lastDotIndex = cleanUrl.lastIndexOf('.');

  if (lastDotIndex === -1) {
    return '';
  }

  return cleanUrl.slice(lastDotIndex).toLowerCase();
};

const isVideoUrl = (url = '') => {
  return videoExtensions.includes(getFileExtensionFromUrl(url));
};

const collectThumbnailLookupUrlsForPresign = ({
  thumbnailUrl,
  fullMediaUrl,
  rawResponse,
}) => {
  return [
    ...new Set(
      [
        thumbnailUrl,
        fullMediaUrl,
        ...getUniqueHttpUrls(rawResponse),
      ].filter(Boolean)
    ),
  ];
};

function PlayIcon() {
  return (
    <svg
      width="34"
      height="34"
      viewBox="0 0 24 24"
      fill="none"
      aria-hidden="true"
    >
      <path d="M9 7.75V16.25L16 12L9 7.75Z" fill="currentColor" />
    </svg>
  );
}

function VideoThumbnailPreview({
  signedThumbnailUrl,
  signedVideoUrl,
  onImageError,
}) {
  return (
    <a
      href={signedVideoUrl}
      target="_blank"
      rel="noreferrer"
      style={{
        display: 'block',
        position: 'relative',
        width: '100%',
        height: '260px',
        textDecoration: 'none',
        overflow: 'hidden',
      }}
    >
      <img
        src={signedThumbnailUrl}
        alt="Video thumbnail lookup result"
        onError={onImageError}
        style={{
          width: '100%',
          height: '260px',
          objectFit: 'cover',
          display: 'block',
        }}
      />

      <div
        style={{
          position: 'absolute',
          inset: 0,
          background:
            'linear-gradient(180deg, rgba(8,28,21,0.08), rgba(8,28,21,0.5))',
        }}
      />

      <div
        style={{
          position: 'absolute',
          left: '50%',
          top: '50%',
          transform: 'translate(-50%, -50%)',
          width: '64px',
          height: '64px',
          borderRadius: '999px',
          background: 'rgba(255, 255, 255, 0.92)',
          color: '#1b4332',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          boxShadow: '0 16px 35px rgba(8, 28, 21, 0.28)',
        }}
      >
        <PlayIcon />
      </div>

      <span
        style={{
          position: 'absolute',
          left: '14px',
          bottom: '14px',
          borderRadius: '999px',
          padding: '7px 11px',
          background: 'rgba(8, 28, 21, 0.84)',
          color: '#ffffff',
          fontSize: '12px',
          fontWeight: 900,
          letterSpacing: '0.05em',
          textTransform: 'uppercase',
        }}
      >
        Video thumbnail
      </span>
    </a>
  );
}

function ThumbnailLookupPanel() {
  const [thumbnailUrl, setThumbnailUrl] = useState('');
  const [fullMediaUrl, setFullMediaUrl] = useState('');
  const [signedUrlMap, setSignedUrlMap] = useState({});
  const [rawResponse, setRawResponse] = useState(null);
  const [loading, setLoading] = useState(false);
  const [previewFailed, setPreviewFailed] = useState(false);
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');

  const cleanedThumbnailUrl = thumbnailUrl.trim();
  const signedThumbnailUrl = getDisplayUrl(cleanedThumbnailUrl, signedUrlMap);
  const signedFullMediaUrl = getDisplayUrl(fullMediaUrl, signedUrlMap);
  const isVideo = isVideoUrl(fullMediaUrl);

  const resetOutput = () => {
    setFullMediaUrl('');
    setSignedUrlMap({});
    setRawResponse(null);
    setPreviewFailed(false);
    setMessage('');
    setError('');
  };

  const handleLookup = async (event) => {
    event.preventDefault();
    resetOutput();

    if (!cleanedThumbnailUrl) {
      setError('Please paste a thumbnail URL before searching.');
      return;
    }

    if (!cleanedThumbnailUrl.startsWith('http')) {
      setError('Please enter a valid thumbnail URL starting with http or https.');
      return;
    }

    setLoading(true);

    try {
      const data = await queryByThumbnailUrl(cleanedThumbnailUrl);
      const resolvedUrl = getFullMediaUrl(data);

      setRawResponse(data);

      if (!resolvedUrl) {
        setError('Lookup completed, but no full-size media URL was returned.');
        return;
      }

      const urlsToPresign = collectThumbnailLookupUrlsForPresign({
        thumbnailUrl: cleanedThumbnailUrl,
        fullMediaUrl: resolvedUrl,
        rawResponse: data,
      });

      const signedUrls = await presignUrls(urlsToPresign);

      setFullMediaUrl(resolvedUrl);
      setSignedUrlMap(signedUrls);
      setMessage('Thumbnail lookup completed successfully.');
    } catch (lookupError) {
      setError(
        lookupError.message ||
          'Thumbnail lookup failed. Please check the thumbnail URL.'
      );
    } finally {
      setLoading(false);
    }
  };

  const handleClear = () => {
    setThumbnailUrl('');
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
            Thumbnail lookup
          </p>

          <h2
            style={{
              margin: '10px 0 10px',
              color: '#081c15',
              fontSize: '32px',
              letterSpacing: '-0.04em',
            }}
          >
            Find media file from thumbnail
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
            Paste a real thumbnail URL returned by the Search Library. The
            protected backend maps the thumbnail to its original full-size image
            or video file. The returned private S3 URL is then converted into a
            short-lived presigned URL for display.
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

          <form onSubmit={handleLookup} style={{ marginTop: '24px' }}>
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
                Thumbnail URL
              </span>

              <textarea
                value={thumbnailUrl}
                onChange={(event) => {
                  setThumbnailUrl(event.target.value);
                  resetOutput();
                }}
                placeholder="Paste raw thumbnail_url from a query result here..."
                rows={5}
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

            <div
              style={{
                display: 'grid',
                gridTemplateColumns: '1fr auto',
                gap: '12px',
                marginTop: '16px',
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
                {loading ? 'Looking up...' : 'Find media file'}
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

          {fullMediaUrl && (
            <div
              style={{
                marginTop: '26px',
                padding: '20px',
                borderRadius: '24px',
                background: '#f8fcf9',
                border: '1px solid #d7e9dd',
              }}
            >
              <p
                style={{
                  margin: 0,
                  color: '#2d6a4f',
                  fontSize: '12px',
                  fontWeight: 900,
                  letterSpacing: '0.08em',
                  textTransform: 'uppercase',
                }}
              >
                Full-size media URL
              </p>

              <a
                href={signedFullMediaUrl || fullMediaUrl}
                target="_blank"
                rel="noreferrer"
                style={{
                  display: 'block',
                  marginTop: '10px',
                  color: '#081c15',
                  fontSize: '14px',
                  lineHeight: 1.6,
                  overflowWrap: 'break-word',
                  fontWeight: 800,
                }}
              >
                {fullMediaUrl}
              </a>

              <a
                href={signedFullMediaUrl || fullMediaUrl}
                target="_blank"
                rel="noreferrer"
                style={{
                  display: 'inline-flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  marginTop: '16px',
                  borderRadius: '16px',
                  padding: '12px 16px',
                  background: '#1b4332',
                  color: '#ffffff',
                  textDecoration: 'none',
                  fontSize: '14px',
                  fontWeight: 900,
                  boxShadow: '0 12px 26px rgba(27, 67, 50, 0.2)',
                }}
              >
                {isVideo ? 'Open video file' : 'Open full image'}
              </a>
            </div>
          )}

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
            Preview
          </p>

          <div
            style={{
              marginTop: '16px',
              borderRadius: '22px',
              background: 'rgba(255, 255, 255, 0.08)',
              border: '1px solid rgba(216, 243, 220, 0.18)',
              minHeight: '230px',
              overflow: 'hidden',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            {!fullMediaUrl && (
              <div style={{ textAlign: 'center', padding: '24px' }}>
                <div style={{ fontSize: '44px', marginBottom: '12px' }}>
                  🖼️
                </div>

                <p
                  style={{
                    margin: 0,
                    color: '#d8f3dc',
                    fontSize: '15px',
                    lineHeight: 1.6,
                    fontWeight: 700,
                  }}
                >
                  The image or video thumbnail preview will appear here after a
                  successful lookup.
                </p>
              </div>
            )}

            {fullMediaUrl && !previewFailed && !isVideo && (
              <img
                src={signedFullMediaUrl || fullMediaUrl}
                alt="Full-size lookup result"
                onError={() => setPreviewFailed(true)}
                style={{
                  width: '100%',
                  height: '260px',
                  objectFit: 'cover',
                  display: 'block',
                }}
              />
            )}

            {fullMediaUrl && !previewFailed && isVideo && (
              <VideoThumbnailPreview
                signedThumbnailUrl={signedThumbnailUrl || cleanedThumbnailUrl}
                signedVideoUrl={signedFullMediaUrl || fullMediaUrl}
                onImageError={() => setPreviewFailed(true)}
              />
            )}

            {fullMediaUrl && previewFailed && (
              <div style={{ textAlign: 'center', padding: '24px' }}>
                <div style={{ fontSize: '40px', marginBottom: '12px' }}>
                  🔗
                </div>

                <p
                  style={{
                    margin: 0,
                    color: '#d8f3dc',
                    fontSize: '15px',
                    lineHeight: 1.6,
                    fontWeight: 700,
                  }}
                >
                  Preview could not be displayed, but the media link is
                  available.
                </p>
              </div>
            )}
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
                Correct input
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
                Use the raw thumbnail_url copied from a Search Library result.
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
                Private media access
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
                The frontend uses /presign before displaying private S3 images
                or video thumbnails.
              </p>
            </div>
          </div>
        </aside>
      </div>
    </section>
  );
}

export default ThumbnailLookupPanel;