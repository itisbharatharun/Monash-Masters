import functions_framework
import requests
import logging
import json

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

AWS_API_GATEWAY_URL = "https://hts5i8gy6g.execute-api.us-east-1.amazonaws.com/prod"

ALLOWED_PATHS = {"/upload", "/query", "/tags", "/files", "/notifications", "/presign"}

FORWARD_HEADERS = {"authorization", "content-type"}


@functions_framework.http
def proxy(request):
    """
    GCP Gen2 HTTP Cloud Function — secure multi-cloud proxy.

    Receives requests from the frontend, validates the path, forwards
    the request to AWS API Gateway with the Cognito JWT intact in the
    Authorization header, and streams the response back to the caller.

    The Cognito JWT is never inspected or stored here — GCP acts purely
    as a transport layer, satisfying the multi-cloud requirement without
    duplicating auth logic.
    """
    if request.method == "OPTIONS":
        return (
            "",
            204,
            {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "POST,GET,DELETE,OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type,Authorization",
                "Access-Control-Max-Age": "3600",
            },
        )

    path = request.path
    if path not in ALLOWED_PATHS:
        logger.warning(f"Rejected unknown path: {path}")
        return (
            json.dumps({"error": f"Unknown route: {path}"}),
            404,
            {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
            },
        )

    forward = {
        k: v
        for k, v in request.headers
        if k.lower() in FORWARD_HEADERS
    }

    target_url = f"{AWS_API_GATEWAY_URL}{path}"
    method = request.method.upper()

    logger.info(f"Forwarding {method} {path} -> {target_url}")

    try:
        aws_response = requests.request(
            method=method,
            url=target_url,
            headers=forward,
            data=request.get_data(),
            params=request.args,
            timeout=29,
            allow_redirects=False,
        )
    except requests.Timeout:
        logger.error(f"Timeout forwarding {method} {path}")
        return (
            json.dumps({"error": "Request to AWS timed out"}),
            504,
            {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
            },
        )
    except requests.RequestException as e:
        logger.error(f"Error forwarding {method} {path}: {e}")
        return (
            json.dumps({"error": "Failed to reach AWS API Gateway"}),
            502,
            {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
            },
        )

    response_headers = {
        "Content-Type": aws_response.headers.get("Content-Type", "application/json"),
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "Content-Type,Authorization",
        "Access-Control-Allow-Methods": "POST,GET,DELETE,OPTIONS",
    }

    logger.info(f"AWS responded {aws_response.status_code} for {method} {path}")

    return (
        aws_response.content,
        aws_response.status_code,
        response_headers,
    )
