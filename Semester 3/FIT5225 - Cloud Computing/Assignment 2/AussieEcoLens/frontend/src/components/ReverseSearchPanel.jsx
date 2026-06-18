import { useEffect, useMemo, useState } from 'react';

import {
  getDisplayUrl,
  getUniqueHttpUrls,
  presignUrls,
  reverseImageSearch,
} from '../services/apiService';

const allowedImageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];

const videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm', '.wmv', '.flv'];

const formatFileSize = (bytes) => {
  if (!bytes && bytes !== 0) {
    return 'Unknown size';
  }

  if (bytes < 1024) {
    return `${bytes} B`;
  }

  if (bytes < 1024 * 1024) {
    return `${(bytes / 1024).toFixed(1)} KB`;
  }

  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
};

const getFileExtension = (filename = '') => {
  const cleanName = filename.split('?')[0];
  const lastDotIndex = cleanName.lastIndexOf('.');

  if (lastDotIndex === -1) {
    return '';
  }

  return cleanName.slice(lastDotIndex).toLowerCase();
};

const isVideoUrl = (url = '') => {
  const extension = getFileExtension(url);
  return videoExtensions.includes(extension);
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

const getResultUrl = (item) => {
  if (typeof item === 'string') {
    return item.startsWith('http') ? item : '';
  }

  const urls = getUniqueHttpUrls(item);

  return (
    item?.file_url ||
    item?.fileUrl ||
    item?.file_url_final ||
    item?.fileUrlFinal ||
    item?.final_url ||
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

const collectReverseResultUrlsForPresign = (results = []) => {
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

function SearchImageIcon() {
  return (
    <svg
      width="38"
      height="38"
      viewBox="0 0 24 24"
      fill="none"
      aria-hidden="true"
    >
      <path
        d="M4.75 6.75C4.75 5.64543 5.64543 4.75 6.75 4.75H14.25C15.3546 4.75 16.25 5.64543 16.25 6.75V14.25C16.25 15.3546 15.3546 16.25 14.25 16.25H6.75C5.64543 16.25 4.75 15.3546 4.75 14.25V6.75Z"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinejoin="round"
      />
      <path
        d="M7.25 13.75L9.6 11.4C10.0971 10.9029 10.9029 10.9029 11.4 11.4L12.25 12.25L13.1 11.4C13.5971 10.9029 14.4029 10.9029 14.9 11.4L16.25 12.75"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M8.75 8.75H8.762"
        stroke="currentColor"
        strokeWidth="2.4"
        strokeLinecap="round"
      />
      <path
        d="M16.75 16.75L21 21"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
      />
      <path
        d="M18.5 18.5C19.6046 17.3954 19.6046 15.6046 18.5 14.5C17.3954 13.3954 15.6046 13.3954 14.5 14.5"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
      />
    </svg>
  );
}

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
              ? 'Video thumbnail unavailable. Use the file link below.'
              : 'Preview unavailable. Use the file link below.'}
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
        alt={isVideo ? 'Video thumbnail result' : 'Reverse search result'}
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
            Match {index + 1}
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
            {isVideo ? 'Open video file' : 'Open matching file'}
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
            No direct file URL was returned for this match.
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

function ReverseSearchPanel() {
  const [selectedFile, setSelectedFile] = useState(null);
  const [previewUrl, setPreviewUrl] = useState('');
  const [isDragging, setIsDragging] = useState(false);
  const [loading, setLoading] = useState(false);
  const [results, setResults] = useState([]);
  const [signedUrlMap, setSignedUrlMap] = useState({});
  const [count, setCount] = useState(0);
  const [rawResponse, setRawResponse] = useState(null);
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');

  const selectedFileExtension = useMemo(() => {
    if (!selectedFile) {
      return '';
    }

    return getFileExtension(selectedFile.name);
  }, [selectedFile]);

  useEffect(() => {
    if (!selectedFile) {
      setPreviewUrl('');
      return undefined;
    }

    const objectUrl = URL.createObjectURL(selectedFile);
    setPreviewUrl(objectUrl);

    return () => {
      URL.revokeObjectURL(objectUrl);
    };
  }, [selectedFile]);

  const resetOutput = () => {
    setResults([]);
    setSignedUrlMap({});
    setCount(0);
    setRawResponse(null);
    setMessage('');
    setError('');
  };

  const validateAndSetFile = (file) => {
    resetOutput();

    if (!file) {
      return;
    }

    const extension = getFileExtension(file.name);

    if (!allowedImageExtensions.includes(extension)) {
      setSelectedFile(null);
      setError('Please choose a valid image file: JPG, PNG, WEBP, GIF, or BMP.');
      return;
    }

    setSelectedFile(file);
  };

  const handleFileChange = (event) => {
    validateAndSetFile(event.target.files?.[0]);
  };

  const handleDrop = (event) => {
    event.preventDefault();
    setIsDragging(false);
    validateAndSetFile(event.dataTransfer.files?.[0]);
  };

  const handleSearch = async (event) => {
    event.preventDefault();
    resetOutput();

    if (!selectedFile) {
      setError('Please choose an image before running reverse search.');
      return;
    }

    setLoading(true);

    try {
      const data = await reverseImageSearch(selectedFile);
      const returnedResults = data.results || [];
      const urlsToPresign = collectReverseResultUrlsForPresign(returnedResults);
      const signedUrls = await presignUrls(urlsToPresign);

      setRawResponse(data);
      setResults(returnedResults);
      setSignedUrlMap(signedUrls);
      setCount(data.count ?? returnedResults.length);
      setMessage(
        `Reverse image search completed. ${
          data.count ?? returnedResults.length
        } match(es) found.`
      );
    } catch (searchError) {
      setError(
        searchError.message ||
          'Reverse image search failed. Please try again with another image.'
      );
    } finally {
      setLoading(false);
    }
  };

  const clearSelection = () => {
    setSelectedFile(null);
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
            Reverse image search
          </p>

          <h2
            style={{
              margin: '10px 0 10px',
              color: '#081c15',
              fontSize: '32px',
              letterSpacing: '-0.04em',
            }}
          >
            Search using a query image
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
            Upload a query image. The backend detects species tags from the
            image and returns matching completed media records. Returned private
            S3 media URLs are converted into presigned URLs before display.
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

          <form onSubmit={handleSearch} style={{ marginTop: '24px' }}>
            <label
              onDragOver={(event) => {
                event.preventDefault();
                setIsDragging(true);
              }}
              onDragLeave={() => setIsDragging(false)}
              onDrop={handleDrop}
              style={{
                display: 'block',
                border: isDragging
                  ? '2px dashed #1b4332'
                  : '2px dashed #95d5b2',
                background: isDragging ? '#edf8f1' : '#f8fcf9',
                borderRadius: '26px',
                padding: '30px',
                cursor: 'pointer',
                transition: 'all 0.2s ease',
              }}
            >
              <input
                type="file"
                accept={allowedImageExtensions.join(',')}
                onChange={handleFileChange}
                style={{ display: 'none' }}
              />

              <div
                style={{
                  display: 'grid',
                  gridTemplateColumns: '76px 1fr',
                  gap: '20px',
                  alignItems: 'center',
                }}
              >
                <div
                  style={{
                    width: '76px',
                    height: '76px',
                    borderRadius: '24px',
                    background:
                      'linear-gradient(135deg, #e9f8ee 0%, #d8f3dc 100%)',
                    border: '1px solid #b7e4c7',
                    color: '#1b4332',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    boxShadow: '0 14px 30px rgba(27, 67, 50, 0.12)',
                  }}
                >
                  <SearchImageIcon />
                </div>

                <div>
                  <h3
                    style={{
                      margin: 0,
                      color: '#081c15',
                      fontSize: '23px',
                      letterSpacing: '-0.03em',
                    }}
                  >
                    Drop query image here or click to browse
                  </h3>

                  <p
                    style={{
                      margin: '8px 0 0',
                      color: '#607166',
                      fontSize: '14px',
                      lineHeight: 1.6,
                    }}
                  >
                    Supported query image formats: JPG, PNG, WEBP, GIF, and BMP.
                  </p>
                </div>
              </div>
            </label>

            {selectedFile && (
              <div
                style={{
                  marginTop: '20px',
                  display: 'grid',
                  gridTemplateColumns: 'minmax(0, 1fr) auto',
                  gap: '14px',
                  alignItems: 'center',
                  padding: '18px',
                  borderRadius: '20px',
                  background: '#f4fbf6',
                  border: '1px solid #d7e9dd',
                }}
              >
                <div>
                  <p
                    style={{
                      margin: 0,
                      color: '#081c15',
                      fontSize: '16px',
                      fontWeight: 900,
                      overflowWrap: 'break-word',
                    }}
                  >
                    {selectedFile.name}
                  </p>

                  <p
                    style={{
                      margin: '6px 0 0',
                      color: '#607166',
                      fontSize: '14px',
                    }}
                  >
                    {formatFileSize(selectedFile.size)} ·{' '}
                    {selectedFile.type || 'Unknown type'} ·{' '}
                    {selectedFileExtension}
                  </p>

                  <p
                    style={{
                      margin: '8px 0 0',
                      color: '#2d6a4f',
                      fontSize: '13px',
                      fontWeight: 800,
                    }}
                  >
                    Ready for reverse search
                  </p>
                </div>

                <button
                  type="button"
                  onClick={clearSelection}
                  style={{
                    border: '1px solid #d7e4dc',
                    background: '#ffffff',
                    color: '#1b4332',
                    borderRadius: '14px',
                    padding: '10px 14px',
                    fontWeight: 900,
                    cursor: 'pointer',
                  }}
                >
                  Clear
                </button>
              </div>
            )}

            <button
              type="submit"
              disabled={loading || !selectedFile}
              style={{
                marginTop: '22px',
                width: '100%',
                border: 'none',
                borderRadius: '18px',
                padding: '16px 18px',
                background:
                  loading || !selectedFile
                    ? '#9fb8a8'
                    : 'linear-gradient(135deg, #1b4332, #2d6a4f)',
                color: '#ffffff',
                fontSize: '16px',
                fontWeight: 900,
                cursor: loading || !selectedFile ? 'not-allowed' : 'pointer',
                boxShadow:
                  loading || !selectedFile
                    ? 'none'
                    : '0 16px 35px rgba(27, 67, 50, 0.24)',
              }}
            >
              {loading ? 'Running reverse search...' : 'Run reverse search'}
            </button>
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
            Query image preview
          </p>

          <div
            style={{
              marginTop: '16px',
              borderRadius: '22px',
              background: 'rgba(255, 255, 255, 0.08)',
              border: '1px solid rgba(216, 243, 220, 0.18)',
              minHeight: '250px',
              overflow: 'hidden',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            {!selectedFile && (
              <div style={{ textAlign: 'center', padding: '24px' }}>
                <div
                  style={{
                    width: '72px',
                    height: '72px',
                    margin: '0 auto 16px',
                    borderRadius: '24px',
                    background: 'rgba(216, 243, 220, 0.12)',
                    color: '#b7e4c7',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                  }}
                >
                  <SearchImageIcon />
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
                  Select a query image to preview it before running reverse
                  search.
                </p>
              </div>
            )}

            {selectedFile && (
              <img
                src={previewUrl}
                alt={selectedFile.name}
                style={{
                  width: '100%',
                  height: '270px',
                  objectFit: 'cover',
                  display: 'block',
                }}
              />
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
                Backend process
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
                Temporary upload → inference query mode → tag matching →
                presigned display URLs
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
                {count > 0 ? `${count} match(es) found` : 'No active matches'}
              </p>
            </div>
          </div>
        </aside>
      </div>

      {results.length > 0 && (
        <div style={{ marginTop: '28px' }}>
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
            Matching results
          </p>

          <h3
            style={{
              margin: '6px 0 16px',
              color: '#081c15',
              fontSize: '26px',
              letterSpacing: '-0.03em',
            }}
          >
            {count} match{count === 1 ? '' : 'es'} found
          </h3>

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

export default ReverseSearchPanel;