import { useEffect, useState } from 'react';

import {
  getDisplayUrl,
  getUniqueHttpUrls,
  presignUrls,
  queryBySpecies,
  queryByTags,
} from '../services/apiService';

const videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm', '.wmv', '.flv'];

const parseTagsInput = (input) => {
  return input
    .split(',')
    .map((item) => item.trim())
    .filter(Boolean)
    .reduce((tagsObject, item) => {
      const [tagPart, countPart] = item.split(':');
      const tag = tagPart.trim().toLowerCase();
      const count = Number.parseInt(countPart, 10);

      if (tag) {
        tagsObject[tag] = Number.isNaN(count) ? 1 : count;
      }

      return tagsObject;
    }, {});
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

const deriveThumbnailUrlFromMediaUrl = (url = '') => {
  if (!url || !url.startsWith('http')) {
    return '';
  }

  if (!url.includes('/media/') || !isVideoUrl(url)) {
    return '';
  }

  try {
    const parsedUrl = new URL(url);
    parsedUrl.pathname = parsedUrl.pathname
      .replace('/media/', '/thumbnails/')
      .replace(/\.[^/.]+$/, '.jpg');

    return parsedUrl.toString();
  } catch {
    return url.replace('/media/', '/thumbnails/').replace(/\.[^/.?]+$/, '.jpg');
  }
};

const collectResultUrlsForPresign = (results = []) => {
  return [
    ...new Set(
      results
        .flatMap((item) => [
          ...getUniqueHttpUrls(item),
          getResultUrl(item),
          getResultThumbnail(item),
        ])
        .filter(Boolean)
    ),
  ];
};

const getResultUrl = (item) => {
  if (typeof item === 'string') {
    return item.startsWith('http') ? item : '';
  }

  const urls = getUniqueHttpUrls(item);

  return (
    item?.file_url_final ||
    item?.fileUrlFinal ||
    item?.final_url ||
    item?.file_url ||
    item?.fileUrl ||
    item?.media_url ||
    item?.image_url ||
    item?.video_url ||
    item?.full_url ||
    item?.fullImageUrl ||
    item?.s3_url ||
    item?.url ||
    urls.find((url) => url.includes('/media/')) ||
    urls[0] ||
    ''
  );
};

const getResultThumbnail = (item) => {
  if (typeof item === 'string') {
    if (!item.startsWith('http')) {
      return '';
    }

    if (item.includes('/thumbnails/')) {
      return item;
    }

    if (isVideoUrl(item)) {
      return deriveThumbnailUrlFromMediaUrl(item);
    }

    return item;
  }

  const fileUrl = getResultUrl(item);
  const urls = getUniqueHttpUrls(item);

  return (
    item?.thumbnail_url ||
    item?.thumbnailUrl ||
    item?.thumbnail ||
    item?.preview_url ||
    item?.previewUrl ||
    urls.find((url) => url.includes('/thumbnails/')) ||
    deriveThumbnailUrlFromMediaUrl(fileUrl) ||
    fileUrl ||
    urls[0] ||
    ''
  );
};

const isVideoResult = (item) => {
  const fileType = String(item?.file_type || item?.type || '').toLowerCase();
  const fileUrl = getResultUrl(item);
  const allUrls = getUniqueHttpUrls(item);

  return (
    fileType.includes('video') ||
    isVideoUrl(fileUrl) ||
    allUrls.some((url) => isVideoUrl(url))
  );
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

function ResultPreview({ item, signedUrlMap }) {
  const rawFileUrl = getResultUrl(item);
  const rawThumbnailUrl = getResultThumbnail(item);

  const fileUrl = getDisplayUrl(rawFileUrl, signedUrlMap);
  const firstImageUrl = getDisplayUrl(rawThumbnailUrl, signedUrlMap);

  const isVideo = isVideoResult(item);
  const [imageSrc, setImageSrc] = useState(firstImageUrl);
  const [imageFailed, setImageFailed] = useState(false);

  useEffect(() => {
    setImageSrc(firstImageUrl);
    setImageFailed(false);
  }, [firstImageUrl]);

  const handleImageError = () => {
    if (!isVideo && imageSrc !== fileUrl && fileUrl) {
      setImageSrc(fileUrl);
      return;
    }

    setImageFailed(true);
  };

  if (imageFailed || !imageSrc) {
    return (
      <div
        style={{
          height: '210px',
          borderRadius: '22px',
          background: '#f4fbf6',
          border: '1px solid #d7e9dd',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          textAlign: 'center',
          padding: '24px',
        }}
      >
        <div>
          <div style={{ fontSize: '38px', marginBottom: '10px' }}>
            {isVideo ? '🎬' : '🖼️'}
          </div>
          <p
            style={{
              margin: 0,
              color: '#607166',
              fontSize: '14px',
              fontWeight: 800,
              lineHeight: 1.5,
            }}
          >
            {isVideo
              ? 'Video thumbnail unavailable. Open the video below.'
              : 'Preview unavailable. Open the full file below.'}
          </p>
        </div>
      </div>
    );
  }

  return (
    <a
      href={fileUrl || imageSrc}
      target="_blank"
      rel="noreferrer"
      style={{
        display: 'block',
        position: 'relative',
        borderRadius: '22px',
        overflow: 'hidden',
        textDecoration: 'none',
      }}
    >
      <img
        src={imageSrc}
        alt={isVideo ? 'Video thumbnail result' : 'Query result'}
        onError={handleImageError}
        style={{
          width: '100%',
          height: '210px',
          objectFit: 'cover',
          display: 'block',
          borderRadius: '22px',
          border: '1px solid #d7e9dd',
          background: '#f4fbf6',
        }}
      />

      {isVideo && (
        <>
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
        </>
      )}
    </a>
  );
}

function ResultCard({ item, index, signedUrlMap }) {
  const rawFileUrl = getResultUrl(item);
  const rawThumbnailUrl = getResultThumbnail(item);

  const fileUrl = getDisplayUrl(rawFileUrl, signedUrlMap);
  const thumbnailUrl = getDisplayUrl(rawThumbnailUrl, signedUrlMap);

  const isVideo = isVideoResult(item);
  const fileType =
    typeof item === 'object'
      ? item.file_type || item.type || (isVideo ? 'video' : 'media')
      : isVideo
        ? 'video'
        : 'media';

  const availableRawUrls = [
    ...new Set([rawFileUrl, rawThumbnailUrl, ...getUniqueHttpUrls(item)].filter(Boolean)),
  ];

  return (
    <article
      style={{
        background: '#ffffff',
        border: '1px solid #d9e2dc',
        borderRadius: '26px',
        padding: '16px',
        boxShadow: '0 16px 40px rgba(8, 28, 21, 0.07)',
      }}
    >
      <ResultPreview item={item} signedUrlMap={signedUrlMap} />

      <div style={{ padding: '16px 4px 4px' }}>
        <div
          style={{
            display: 'flex',
            justifyContent: 'space-between',
            gap: '12px',
            alignItems: 'center',
            marginBottom: '12px',
          }}
        >
          <h3
            style={{
              margin: 0,
              color: '#081c15',
              fontSize: '18px',
              letterSpacing: '-0.03em',
            }}
          >
            Result {index + 1}
          </h3>

          <span
            style={{
              display: 'inline-flex',
              alignItems: 'center',
              borderRadius: '999px',
              padding: '6px 10px',
              background: '#e9f8ee',
              color: '#1b4332',
              fontSize: '12px',
              fontWeight: 900,
              textTransform: 'uppercase',
              letterSpacing: '0.04em',
            }}
          >
            {fileType}
          </span>
        </div>

        {fileUrl ? (
          <a
            href={fileUrl}
            target="_blank"
            rel="noreferrer"
            style={{
              display: 'inline-flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '8px',
              width: '100%',
              borderRadius: '16px',
              padding: '12px 14px',
              background: '#1b4332',
              color: '#ffffff',
              textDecoration: 'none',
              fontSize: '14px',
              fontWeight: 900,
              boxShadow: '0 12px 26px rgba(27, 67, 50, 0.2)',
            }}
          >
            {isVideo ? 'Open video file' : 'Open full file'}
          </a>
        ) : (
          <div
            style={{
              borderRadius: '16px',
              padding: '12px 14px',
              background: '#fff7ed',
              border: '1px solid #fed7aa',
              color: '#9a3412',
              fontSize: '13px',
              fontWeight: 800,
              lineHeight: 1.5,
              textAlign: 'center',
            }}
          >
            No direct file URL was returned for this result.
          </div>
        )}

        {rawThumbnailUrl && rawThumbnailUrl !== rawFileUrl && (
          <details
            style={{
              marginTop: '14px',
              borderRadius: '16px',
              background: '#f8fcf9',
              border: '1px solid #d7e9dd',
              padding: '12px',
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
              Thumbnail URL
            </summary>

            <a
              href={thumbnailUrl || rawThumbnailUrl}
              target="_blank"
              rel="noreferrer"
              style={{
                display: 'block',
                marginTop: '10px',
                color: '#081c15',
                fontSize: '12px',
                lineHeight: 1.5,
                overflowWrap: 'break-word',
                fontWeight: 700,
              }}
            >
              {rawThumbnailUrl}
            </a>
          </details>
        )}

        {availableRawUrls.length > 0 && (
          <details
            style={{
              marginTop: '10px',
              borderRadius: '16px',
              background: '#f8fcf9',
              border: '1px solid #d7e9dd',
              padding: '12px',
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
              Available result URLs
            </summary>

            {availableRawUrls.map((rawUrl, urlIndex) => {
              const signedUrl = getDisplayUrl(rawUrl, signedUrlMap);

              return (
                <a
                  key={`${rawUrl}-${urlIndex}`}
                  href={signedUrl}
                  target="_blank"
                  rel="noreferrer"
                  style={{
                    display: 'block',
                    marginTop: '10px',
                    color: '#081c15',
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
    </article>
  );
}

function QueryPanel() {
  const [activeQuery, setActiveQuery] = useState('species');
  const [species, setSpecies] = useState('');
  const [tagsInput, setTagsInput] = useState('');
  const [loading, setLoading] = useState(false);
  const [results, setResults] = useState([]);
  const [signedUrlMap, setSignedUrlMap] = useState({});
  const [count, setCount] = useState(0);
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');

  const resetOutput = () => {
    setResults([]);
    setSignedUrlMap({});
    setCount(0);
    setMessage('');
    setError('');
  };

  const applyQueryResults = async (data, successMessage) => {
    const returnedResults = data.results || [];
    const urlsToPresign = collectResultUrlsForPresign(returnedResults);
    const signedUrls = await presignUrls(urlsToPresign);

    setResults(returnedResults);
    setSignedUrlMap(signedUrls);
    setCount(data.count ?? returnedResults.length);
    setMessage(successMessage);
  };

  const handleSpeciesQuery = async (event) => {
    event.preventDefault();
    resetOutput();

    const cleanedSpecies = species.trim().toLowerCase();

    if (!cleanedSpecies) {
      setError('Please enter a species tag, for example: cat, wombat, dingo.');
      return;
    }

    setLoading(true);

    try {
      const data = await queryBySpecies(cleanedSpecies);
      await applyQueryResults(
        data,
        `Species query completed for "${cleanedSpecies}".`
      );
    } catch (queryError) {
      setError(queryError.message || 'Species query failed.');
    } finally {
      setLoading(false);
    }
  };

  const handleTagsQuery = async (event) => {
    event.preventDefault();
    resetOutput();

    const parsedTags = parseTagsInput(tagsInput);

    if (Object.keys(parsedTags).length === 0) {
      setError('Please enter at least one tag, for example: cat:1, bird:2.');
      return;
    }

    setLoading(true);

    try {
      const data = await queryByTags(parsedTags);
      await applyQueryResults(data, 'Tag query completed.');
    } catch (queryError) {
      setError(queryError.message || 'Tag query failed.');
    } finally {
      setLoading(false);
    }
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
          gridTemplateColumns: 'minmax(0, 0.95fr) minmax(360px, 0.55fr)',
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
            Media search
          </p>

          <h2
            style={{
              margin: '10px 0 10px',
              color: '#081c15',
              fontSize: '32px',
              letterSpacing: '-0.04em',
            }}
          >
            Search wildlife library
          </h2>

          <p
            style={{
              margin: 0,
              color: '#607166',
              fontSize: '16px',
              lineHeight: 1.65,
              maxWidth: '780px',
            }}
          >
            Search completed records in DynamoDB by species name or by tag
            counts. Images and videos are displayed using short-lived presigned
            URLs because the media bucket is private.
          </p>

          <div
            style={{
              display: 'grid',
              gridTemplateColumns: 'repeat(2, minmax(0, 1fr))',
              gap: '12px',
              marginTop: '24px',
            }}
          >
            <button
              type="button"
              onClick={() => {
                setActiveQuery('species');
                resetOutput();
              }}
              style={{
                border:
                  activeQuery === 'species'
                    ? '1px solid #1b4332'
                    : '1px solid #d7e4dc',
                background:
                  activeQuery === 'species'
                    ? 'linear-gradient(135deg, #1b4332, #2d6a4f)'
                    : '#f8fcf9',
                color: activeQuery === 'species' ? '#ffffff' : '#1b4332',
                borderRadius: '18px',
                padding: '15px 16px',
                fontSize: '15px',
                fontWeight: 900,
                cursor: 'pointer',
                boxShadow:
                  activeQuery === 'species'
                    ? '0 14px 30px rgba(27, 67, 50, 0.2)'
                    : 'none',
              }}
            >
              Search by species
            </button>

            <button
              type="button"
              onClick={() => {
                setActiveQuery('tags');
                resetOutput();
              }}
              style={{
                border:
                  activeQuery === 'tags'
                    ? '1px solid #1b4332'
                    : '1px solid #d7e4dc',
                background:
                  activeQuery === 'tags'
                    ? 'linear-gradient(135deg, #1b4332, #2d6a4f)'
                    : '#f8fcf9',
                color: activeQuery === 'tags' ? '#ffffff' : '#1b4332',
                borderRadius: '18px',
                padding: '15px 16px',
                fontSize: '15px',
                fontWeight: 900,
                cursor: 'pointer',
                boxShadow:
                  activeQuery === 'tags'
                    ? '0 14px 30px rgba(27, 67, 50, 0.2)'
                    : 'none',
              }}
            >
              Search by tags
            </button>
          </div>

          {activeQuery === 'species' && (
            <form onSubmit={handleSpeciesQuery} style={{ marginTop: '22px' }}>
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
                  Species tag
                </span>

                <input
                  type="text"
                  value={species}
                  onChange={(event) => setSpecies(event.target.value)}
                  placeholder="Example: cat"
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

              <button
                type="submit"
                disabled={loading}
                style={{
                  marginTop: '16px',
                  width: '100%',
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
                {loading ? 'Searching...' : 'Search species'}
              </button>
            </form>
          )}

          {activeQuery === 'tags' && (
            <form onSubmit={handleTagsQuery} style={{ marginTop: '22px' }}>
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
                  Tags and minimum counts
                </span>

                <input
                  type="text"
                  value={tagsInput}
                  onChange={(event) => setTagsInput(event.target.value)}
                  placeholder="Example: cat:1, bird:2"
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
                Use comma-separated values. Count is optional, so
                <strong> cat </strong>
                is treated as
                <strong> cat:1</strong>.
              </p>

              <button
                type="submit"
                disabled={loading}
                style={{
                  marginTop: '16px',
                  width: '100%',
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
                {loading ? 'Searching...' : 'Search tags'}
              </button>
            </form>
          )}
        </div>

        <aside
          style={{
            borderRadius: '26px',
            background:
              'linear-gradient(145deg, rgba(8, 28, 21, 0.96), rgba(27, 67, 50, 0.94))',
            padding: '22px',
            color: '#ffffff',
            minHeight: '300px',
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
            Search guide
          </p>

          <h3
            style={{
              margin: '12px 0',
              color: '#ffffff',
              fontSize: '24px',
              letterSpacing: '-0.03em',
            }}
          >
            Demo-friendly queries
          </h3>

          <div style={{ display: 'grid', gap: '12px', marginTop: '18px' }}>
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
                Species example
              </p>

              <p
                style={{
                  margin: '6px 0 0',
                  color: '#ffffff',
                  fontSize: '15px',
                  fontWeight: 800,
                }}
              >
                cat, wombat, dingo, kookaburra
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
                Tag example
              </p>

              <p
                style={{
                  margin: '6px 0 0',
                  color: '#ffffff',
                  fontSize: '15px',
                  fontWeight: 800,
                }}
              >
                cat:1, bird:2
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
                Result count
              </p>

              <p
                style={{
                  margin: '6px 0 0',
                  color: '#ffffff',
                  fontSize: '15px',
                  fontWeight: 800,
                }}
              >
                {count > 0 ? `${count} result(s) found` : 'No active results'}
              </p>
            </div>
          </div>
        </aside>
      </div>

      {(message || error) && (
        <div
          style={{
            marginTop: '24px',
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

      {results.length > 0 && (
        <div style={{ marginTop: '28px' }}>
          <div
            style={{
              display: 'flex',
              justifyContent: 'space-between',
              gap: '16px',
              alignItems: 'center',
              marginBottom: '16px',
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
                Query results
              </p>

              <h3
                style={{
                  margin: '6px 0 0',
                  color: '#081c15',
                  fontSize: '26px',
                  letterSpacing: '-0.03em',
                }}
              >
                {count} result{count === 1 ? '' : 's'} found
              </h3>
            </div>
          </div>

          <div
            style={{
              display: 'grid',
              gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))',
              gap: '18px',
            }}
          >
            {results.map((item, index) => (
              <ResultCard
                key={`${getResultUrl(item)}-${index}`}
                item={item}
                index={index}
                signedUrlMap={signedUrlMap}
              />
            ))}
          </div>
        </div>
      )}
    </section>
  );
}

export default QueryPanel;