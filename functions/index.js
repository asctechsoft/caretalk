const { onRequest } = require("firebase-functions/v2/https");
const axios = require("axios");

const BACKEND_URL = "http://103.48.84.161:8888";

/**
 * Proxy function: forward tất cả request từ HTTPS → HTTP backend
 * Giải quyết Mixed Content error khi deploy Flutter web lên Firebase Hosting
 */
exports.api = onRequest(
  {
    cors: true,
    timeoutSeconds: 60,
    region: "asia-southeast1", // Singapore - gần VN nhất
  },
  async (req, res) => {
    // Build target URL: /api/... → http://backend/api/...
    const targetUrl = `${BACKEND_URL}${req.path}`;

    console.log(`[PROXY] ${req.method} ${targetUrl}`);

    // Forward headers (bỏ host để tránh lỗi)
    const headers = { ...req.headers };
    delete headers["host"];
    delete headers["content-length"];

    try {
      const response = await axios({
        method: req.method,
        url: targetUrl,
        params: req.query,
        data: req.body,
        headers: headers,
        responseType: "stream",
        timeout: 55000,
        // Bỏ qua SSL verification (không cần vì backend là HTTP)
        maxRedirects: 5,
      });

      // Forward status và headers từ backend
      res.status(response.status);

      // Copy headers quan trọng
      const responseHeaders = response.headers;
      if (responseHeaders["content-type"]) {
        res.setHeader("content-type", responseHeaders["content-type"]);
      }
      if (responseHeaders["transfer-encoding"]) {
        res.setHeader(
          "transfer-encoding",
          responseHeaders["transfer-encoding"]
        );
      }

      // Pipe stream response về client
      response.data.pipe(res);
    } catch (error) {
      console.error(`[PROXY ERROR] ${error.message}`);

      if (error.response) {
        res.status(error.response.status).json({
          error: "Backend error",
          status: error.response.status,
          message: error.message,
        });
      } else {
        res.status(502).json({
          error: "Bad Gateway",
          message: `Không thể kết nối tới backend: ${error.message}`,
        });
      }
    }
  }
);
