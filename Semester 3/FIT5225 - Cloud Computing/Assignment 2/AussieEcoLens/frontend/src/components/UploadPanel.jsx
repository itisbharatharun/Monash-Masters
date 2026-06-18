import { useEffect, useMemo, useState } from 'react';

import { requestUploadUrl, uploadFileToS3 } from '../services/apiService';

const allowedExtensions = [
  '.jpg',
  '.jpeg',
  '.png',
  '.gif',
  '.bmp',
  '.webp',
  '.mp4',
  '.avi',
  '.mov',
  '.mkv',
  '.wmv',
  '.flv',
  '.webm',
];

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

const getFileExtension = (filename) => {
  const lastDotIndex = filename.lastIndexOf('.');

  if (lastDotIndex === -1) {
    return '';
  }

  return filename.slice(lastDotIndex).toLowerCase();
};

function UploadCloudIcon() {
  return (
    <svg
      width="38"
      height="38"
      viewBox="0 0 24 24"
      fill="none"
      aria-hidden="true"
    >
      <path
        d="M16.5 19H17.5C19.9853 19 22 16.9853 22 14.5C22 12.0147 19.9853 10 17.5 10C17.2744 10 17.0527 10.0166 16.8359 10.0487C16.1986 7.14694 13.6135 5 10.5 5C6.91015 5 4 7.91015 4 11.5C4 11.6766 4.00703 11.8515 4.02082 12.0245C2.24662 12.4205 1 13.9994 1 15.85C1 18.0259 2.76406 19.79 4.94 19.79H7.5"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M12 20V12"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
      />
      <path
        d="M8.75 15.25L12 12L15.25 15.25"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function UploadPanel() {
  const [selectedFile, setSelectedFile] = useState(null);
  const [previewUrl, setPreviewUrl] = useState('');
  const [isDragging, setIsDragging] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');
  const [uploadedFileUrl, setUploadedFileUrl] = useState('');

  const fileType = useMemo(() => {
    if (!selectedFile) {
      return '';
    }

    if (selectedFile.type.startsWith('image/')) {
      return 'image';
    }

    if (selectedFile.type.startsWith('video/')) {
      return 'video';
    }

    return 'file';
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

  const validateAndSetFile = (file) => {
    setMessage('');
    setError('');
    setUploadedFileUrl('');

    if (!file) {
      return;
    }

    const extension = getFileExtension(file.name);

    if (!allowedExtensions.includes(extension)) {
      setSelectedFile(null);
      setError(
        'Unsupported file type. Please upload a valid image or video file.'
      );
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

  const handleUpload = async (event) => {
    event.preventDefault();

    setMessage('');
    setError('');
    setUploadedFileUrl('');

    if (!selectedFile) {
      setError('Please choose an image or video file before uploading.');
      return;
    }

    setUploading(true);

    try {
      const uploadData = await requestUploadUrl(selectedFile);

      await uploadFileToS3({
        uploadUrl: uploadData.upload_url,
        file: selectedFile,
      });

      setUploadedFileUrl(uploadData.file_url || '');
      setMessage(
        'Upload successful. The backend pipeline will now process the file and generate tags/thumbnails.'
      );
    } catch (uploadError) {
      setError(
        uploadError.message ||
          'Upload failed. Please check the file and try again.'
      );
    } finally {
      setUploading(false);
    }
  };

  const clearSelection = () => {
    setSelectedFile(null);
    setMessage('');
    setError('');
    setUploadedFileUrl('');
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
            File upload
          </p>

          <h2
            style={{
              margin: '10px 0 10px',
              color: '#081c15',
              fontSize: '32px',
              letterSpacing: '-0.04em',
            }}
          >
            Upload wildlife media
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
            Upload an image or video through the protected GCP proxy. The
            frontend requests a presigned S3 URL, uploads the file to S3, and
            the backend pipeline handles classification and thumbnail creation.
          </p>

          {message && (
            <div
              style={{
                marginTop: '22px',
                padding: '16px 18px',
                borderRadius: '18px',
                background: '#e9f8ee',
                border: '1px solid #b7e4c7',
                color: '#1b4332',
                fontSize: '14px',
                fontWeight: 800,
                lineHeight: 1.5,
              }}
            >
              {message}
            </div>
          )}

          {error && (
            <div
              style={{
                marginTop: '22px',
                padding: '16px 18px',
                borderRadius: '18px',
                background: '#fff1f2',
                border: '1px solid #fecdd3',
                color: '#9f1239',
                fontSize: '14px',
                fontWeight: 800,
                lineHeight: 1.5,
              }}
            >
              {error}
            </div>
          )}

          <form onSubmit={handleUpload} style={{ marginTop: '24px' }}>
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
                accept={allowedExtensions.join(',')}
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
                  <UploadCloudIcon />
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
                    Drop media here or click to browse
                  </h3>

                  <p
                    style={{
                      margin: '8px 0 0',
                      color: '#607166',
                      fontSize: '14px',
                      lineHeight: 1.6,
                    }}
                  >
                    Supported formats: JPG, PNG, WEBP, GIF, BMP, MP4, MOV, AVI,
                    MKV, WMV, FLV, and WEBM.
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
                    {selectedFile.type || 'Unknown type'}
                  </p>

                  <p
                    style={{
                      margin: '8px 0 0',
                      color: '#2d6a4f',
                      fontSize: '13px',
                      fontWeight: 800,
                    }}
                  >
                    Ready for upload
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
              disabled={uploading || !selectedFile}
              style={{
                marginTop: '22px',
                width: '100%',
                border: 'none',
                borderRadius: '18px',
                padding: '16px 18px',
                background:
                  uploading || !selectedFile
                    ? '#9fb8a8'
                    : 'linear-gradient(135deg, #1b4332, #2d6a4f)',
                color: '#ffffff',
                fontSize: '16px',
                fontWeight: 900,
                cursor: uploading || !selectedFile ? 'not-allowed' : 'pointer',
                boxShadow:
                  uploading || !selectedFile
                    ? 'none'
                    : '0 16px 35px rgba(27, 67, 50, 0.24)',
              }}
            >
              {uploading ? 'Uploading to S3...' : 'Upload media'}
            </button>
          </form>

          {uploadedFileUrl && (
            <div
              style={{
                marginTop: '22px',
                padding: '18px',
                borderRadius: '20px',
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
                Uploaded file URL
              </p>

              <a
                href={uploadedFileUrl}
                target="_blank"
                rel="noreferrer"
                style={{
                  display: 'block',
                  marginTop: '8px',
                  color: '#081c15',
                  fontSize: '14px',
                  lineHeight: 1.5,
                  overflowWrap: 'break-word',
                  fontWeight: 700,
                }}
              >
                {uploadedFileUrl}
              </a>

              <p
                style={{
                  margin: '12px 0 0',
                  color: '#607166',
                  fontSize: '14px',
                  lineHeight: 1.6,
                }}
              >
                Wait a few minutes before querying. The backend still needs to
                run deduplication, inference, thumbnail generation, and DynamoDB
                updates.
              </p>
            </div>
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
                  <UploadCloudIcon />
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
                  Select a wildlife image or video to preview it before upload.
                </p>
              </div>
            )}

            {selectedFile && fileType === 'image' && (
              <img
                src={previewUrl}
                alt={selectedFile.name}
                style={{
                  width: '100%',
                  height: '260px',
                  objectFit: 'cover',
                  display: 'block',
                }}
              />
            )}

            {selectedFile && fileType === 'video' && (
              <video
                src={previewUrl}
                controls
                style={{
                  width: '100%',
                  height: '260px',
                  objectFit: 'cover',
                  display: 'block',
                }}
              />
            )}

            {selectedFile && fileType === 'file' && (
              <div style={{ textAlign: 'center', padding: '24px' }}>
                <p
                  style={{
                    margin: 0,
                    color: '#d8f3dc',
                    fontSize: '15px',
                    lineHeight: 1.6,
                    fontWeight: 700,
                  }}
                >
                  File selected.
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
                Upload path
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
                Browser → GCP Proxy → Presigned S3 URL → S3 Bucket
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
                Next steps
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
                Deduplication, inference, thumbnail generation, and DynamoDB
                update.
              </p>
            </div>
          </div>
        </aside>
      </div>
    </section>
  );
}

export default UploadPanel;