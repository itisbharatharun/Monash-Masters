import { API_BASE_URL } from '../config/appConfig';
import { getIdToken } from './authService';

const PRESIGNED_CACHE_TIME_MS = 55 * 60 * 1000;
const presignedUrlCache = new Map();

const buildApiUrl = (path) => {
  const cleanBaseUrl = API_BASE_URL.replace(/\/$/, '');
  const cleanPath = path.startsWith('/') ? path : `/${path}`;

  return `${cleanBaseUrl}${cleanPath}`;
};

const parseApiResponse = async (response) => {
  const contentType = response.headers.get('content-type') || '';

  if (contentType.includes('application/json')) {
    return response.json();
  }

  const text = await response.text();

  if (!text) {
    return {};
  }

  try {
    return JSON.parse(text);
  } catch {
    return { message: text };
  }
};

const apiRequest = async (path, options = {}) => {
  const token = await getIdToken();

  const response = await fetch(buildApiUrl(path), {
    ...options,
    headers: {
      Authorization: token,
      'Content-Type': 'application/json',
      ...(options.headers || {}),
    },
  });

  const data = await parseApiResponse(response);

  if (!response.ok) {
    throw new Error(
      data.error ||
        data.message ||
        `Request failed with status ${response.status}`
    );
  }

  return data;
};

const fileToBase64 = (file) => {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();

    reader.onload = () => {
      const result = String(reader.result || '');
      const base64 = result.includes(',') ? result.split(',')[1] : result;
      resolve(base64);
    };

    reader.onerror = () => {
      reject(new Error('Could not read the selected file.'));
    };

    reader.readAsDataURL(file);
  });
};

const getFileExtension = (filename = '') => {
  const cleanName = filename.split('?')[0];
  const lastDotIndex = cleanName.lastIndexOf('.');

  if (lastDotIndex === -1) {
    return '';
  }

  return cleanName.slice(lastDotIndex).toLowerCase();
};

const isHttpUrl = (value) => {
  return typeof value === 'string' && value.startsWith('http');
};

const isS3Url = (url = '') => {
  return (
    typeof url === 'string' &&
    url.startsWith('http') &&
    url.includes('.s3.amazonaws.com/')
  );
};

const isAlreadyPresignedUrl = (url = '') => {
  return (
    typeof url === 'string' &&
    (url.includes('X-Amz-Signature=') ||
      url.includes('X-Amz-Algorithm=') ||
      url.includes('X-Amz-Credential='))
  );
};

const stripS3QueryParams = (url = '') => {
  if (!url || typeof url !== 'string') {
    return '';
  }

  const trimmedUrl = url.trim();

  try {
    const parsedUrl = new URL(trimmedUrl);

    if (parsedUrl.hostname.includes('.s3.amazonaws.com')) {
      parsedUrl.search = '';
      parsedUrl.hash = '';
      return parsedUrl.toString();
    }

    return trimmedUrl;
  } catch {
    return trimmedUrl.split('?')[0];
  }
};

const isThumbnailUrl = (url = '') => {
  const cleanUrl = stripS3QueryParams(url);
  return cleanUrl.includes('/thumbnails/');
};

const getFullMediaUrlFromThumbnailResponse = (data) => {
  return (
    data?.file_url ||
    data?.fileUrl ||
    data?.file_url_final ||
    data?.fileUrlFinal ||
    data?.full_url ||
    data?.fullUrl ||
    data?.full_image_url ||
    data?.fullImageUrl ||
    data?.full_size_url ||
    data?.fullSizeUrl ||
    data?.full_media_url ||
    data?.fullMediaUrl ||
    data?.media_url ||
    data?.mediaUrl ||
    data?.video_url ||
    data?.videoUrl ||
    data?.url ||
    data?.result?.file_url ||
    data?.result?.fileUrl ||
    data?.result?.file_url_final ||
    data?.result?.fileUrlFinal ||
    data?.result?.full_url ||
    data?.result?.fullUrl ||
    data?.result?.full_media_url ||
    data?.result?.fullMediaUrl ||
    data?.result?.media_url ||
    data?.result?.mediaUrl ||
    data?.result?.video_url ||
    data?.result?.videoUrl ||
    data?.result?.url ||
    ''
  );
};

const getCachedPresignedUrl = (url) => {
  const cached = presignedUrlCache.get(url);

  if (!cached) {
    return '';
  }

  if (cached.expiresAt <= Date.now()) {
    presignedUrlCache.delete(url);
    return '';
  }

  return cached.signedUrl;
};

const setCachedPresignedUrl = (url, signedUrl) => {
  presignedUrlCache.set(url, {
    signedUrl,
    expiresAt: Date.now() + PRESIGNED_CACHE_TIME_MS,
  });
};

export const collectHttpUrls = (value, urls = []) => {
  if (!value) {
    return urls;
  }

  if (typeof value === 'string') {
    if (isHttpUrl(value)) {
      urls.push(value);
    }

    return urls;
  }

  if (Array.isArray(value)) {
    value.forEach((item) => collectHttpUrls(item, urls));
    return urls;
  }

  if (typeof value === 'object') {
    Object.values(value).forEach((item) => collectHttpUrls(item, urls));
  }

  return urls;
};

export const getUniqueHttpUrls = (value) => {
  return [...new Set(collectHttpUrls(value))];
};

export const getDisplayUrl = (rawUrl, signedUrlMap = {}) => {
  if (!rawUrl) {
    return '';
  }

  const cleanRawUrl = stripS3QueryParams(rawUrl);

  return signedUrlMap[rawUrl] || signedUrlMap[cleanRawUrl] || rawUrl;
};

export const presignUrls = async (urls = []) => {
  const uniqueUrls = [
    ...new Set(
      urls
        .filter(Boolean)
        .filter(isHttpUrl)
        .filter((url) => !isAlreadyPresignedUrl(url))
        .map((url) => stripS3QueryParams(url))
    ),
  ];

  if (uniqueUrls.length === 0) {
    return {};
  }

  const outputMap = {};

  const urlsToPresign = uniqueUrls.filter((url) => {
    const cachedSignedUrl = getCachedPresignedUrl(url);

    if (cachedSignedUrl) {
      outputMap[url] = cachedSignedUrl;
      return false;
    }

    return isS3Url(url);
  });

  uniqueUrls.forEach((url) => {
    if (!isS3Url(url)) {
      outputMap[url] = url;
    }
  });

  if (urlsToPresign.length === 0) {
    return outputMap;
  }

  const data = await apiRequest('/presign', {
    method: 'POST',
    body: JSON.stringify({
      urls: urlsToPresign,
    }),
  });

  const signedUrls = data.signed_urls || {};

  urlsToPresign.forEach((url) => {
    const signedUrl = signedUrls[url] || url;
    outputMap[url] = signedUrl;

    if (signedUrl !== url) {
      setCachedPresignedUrl(url, signedUrl);
    }
  });

  return outputMap;
};

export const requestUploadUrl = async (file) => {
  return apiRequest('/upload', {
    method: 'POST',
    body: JSON.stringify({
      filename: file.name,
      content_type: file.type || 'application/octet-stream',
    }),
  });
};

export const uploadFileToS3 = async ({ uploadUrl, file }) => {
  const response = await fetch(uploadUrl, {
    method: 'PUT',
    headers: {
      'Content-Type': file.type || 'application/octet-stream',
    },
    body: file,
  });

  if (!response.ok) {
    throw new Error(`S3 upload failed with status ${response.status}`);
  }

  return true;
};

export const queryByTags = async (tags) => {
  return apiRequest('/query', {
    method: 'POST',
    body: JSON.stringify({
      query_type: 'tags',
      tags,
    }),
  });
};

export const queryBySpecies = async (species) => {
  return apiRequest('/query', {
    method: 'POST',
    body: JSON.stringify({
      query_type: 'species',
      species,
    }),
  });
};

export const queryByThumbnailUrl = async (thumbnailUrl) => {
  return apiRequest('/query', {
    method: 'POST',
    body: JSON.stringify({
      query_type: 'thumbnail_url',
      thumbnail_url: stripS3QueryParams(thumbnailUrl),
    }),
  });
};

export const resolveUrlsForManagement = async (urls = []) => {
  const cleanUrls = [
    ...new Set(
      urls
        .map((url) => stripS3QueryParams(String(url || '').trim()))
        .filter(Boolean)
    ),
  ];

  if (cleanUrls.length === 0) {
    return [];
  }

  const resolvedUrls = await Promise.all(
    cleanUrls.map(async (url) => {
      if (!isThumbnailUrl(url)) {
        return url;
      }

      const lookupResponse = await queryByThumbnailUrl(url);
      const fullMediaUrl =
        getFullMediaUrlFromThumbnailResponse(lookupResponse);

      if (!fullMediaUrl) {
        throw new Error(
          `Could not resolve thumbnail URL to full media URL: ${url}`
        );
      }

      return stripS3QueryParams(fullMediaUrl);
    })
  );

  return [...new Set(resolvedUrls)];
};

export const reverseImageSearch = async (file) => {
  const base64Content = await fileToBase64(file);
  const fileExtension = getFileExtension(file.name);

  return apiRequest('/query', {
    method: 'POST',
    body: JSON.stringify({
      query_type: 'file',
      file_content: base64Content,
      file_extension: fileExtension,
    }),
  });
};

export const updateFileTags = async ({ urls, tags, operation }) => {
  const resolvedUrls = await resolveUrlsForManagement(urls);

  const operationValue =
    operation === 'add' || operation === 1 || operation === '1' ? 1 : 0;

  return apiRequest('/tags', {
    method: 'POST',
    body: JSON.stringify({
      urls: resolvedUrls,
      tags,
      operation: operationValue,
    }),
  });
};

export const deleteFiles = async (urls) => {
  const resolvedUrls = await resolveUrlsForManagement(urls);

  return apiRequest('/files', {
    method: 'DELETE',
    body: JSON.stringify({
      urls: resolvedUrls,
    }),
  });
};

export const subscribeToNotifications = async ({ email, species }) => {
  return apiRequest('/notifications', {
    method: 'POST',
    body: JSON.stringify({
      operation: 'subscribe',
      email,
      species,
    }),
  });
};

export const unsubscribeFromNotifications = async (email) => {
  return apiRequest('/notifications', {
    method: 'POST',
    body: JSON.stringify({
      operation: 'unsubscribe',
      email,
    }),
  });
};