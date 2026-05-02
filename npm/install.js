#!/usr/bin/env node
"use strict";

const https = require("https");
const http = require("http");
const fs = require("fs");
const path = require("path");
const crypto = require("crypto");
const { execSync } = require("child_process");
const os = require("os");

const REPO = "control-theory/dstl8";
const BINARY = "dstl8";

function getPlatform() {
  const platform = os.platform();
  const arch = os.arch();

  const osMap = { darwin: "darwin", linux: "linux" };
  const archMap = { x64: "amd64", arm64: "arm64" };

  const mappedOs = osMap[platform];
  const mappedArch = archMap[arch];

  if (!mappedOs) {
    throw new Error(`Unsupported platform: ${platform}. Only macOS and Linux are supported.`);
  }
  if (!mappedArch) {
    throw new Error(`Unsupported architecture: ${arch}. Only x64 and arm64 are supported.`);
  }

  return { os: mappedOs, arch: mappedArch };
}

function getVersion() {
  const pkg = require("./package.json");
  return pkg.version;
}

function fetch(url) {
  return new Promise((resolve, reject) => {
    const handler = (res) => {
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
        fetch(res.headers.location).then(resolve, reject);
        return;
      }
      if (res.statusCode !== 200) {
        reject(new Error(`HTTP ${res.statusCode} for ${url}`));
        return;
      }
      const chunks = [];
      res.on("data", (chunk) => chunks.push(chunk));
      res.on("end", () => resolve(Buffer.concat(chunks)));
      res.on("error", reject);
    };

    const mod = url.startsWith("https") ? https : http;
    mod.get(url, { headers: { "User-Agent": "dstl8-npm-installer" } }, handler).on("error", reject);
  });
}

async function main() {
  const { os: goos, arch } = getPlatform();
  const version = getVersion();

  const archiveName = `${BINARY}_${version}_${goos}_${arch}.tar.gz`;
  const baseUrl = `https://github.com/${REPO}/releases/download/v${version}`;
  const archiveUrl = `${baseUrl}/${archiveName}`;
  const checksumsUrl = `${baseUrl}/SHA256SUMS`;

  console.log(`Installing ${BINARY} v${version} (${goos}/${arch})...`);

  // Download archive and checksums in parallel.
  const [archiveData, checksumsData] = await Promise.all([
    fetch(archiveUrl),
    fetch(checksumsUrl),
  ]);

  // Verify checksum.
  const checksums = checksumsData.toString("utf8");
  const line = checksums.split("\n").find((l) => l.includes(archiveName));
  if (!line) {
    throw new Error(`No checksum found for ${archiveName} in SHA256SUMS`);
  }
  const expected = line.trim().split(/\s+/)[0];
  const actual = crypto.createHash("sha256").update(archiveData).digest("hex");

  if (expected !== actual) {
    throw new Error(
      `Checksum mismatch for ${archiveName}\n` +
      `  expected: ${expected}\n` +
      `  actual:   ${actual}\n\n` +
      `The download may be corrupted or tampered with. Aborting.`
    );
  }

  // Write archive to temp file and extract.
  const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), "dstl8-"));
  const archivePath = path.join(tmpDir, archiveName);
  fs.writeFileSync(archivePath, archiveData);

  execSync(`tar -xzf "${archivePath}" -C "${tmpDir}"`);

  // Move binary into package directory.
  const srcBinary = path.join(tmpDir, BINARY);
  const destBinary = path.join(__dirname, BINARY);
  fs.copyFileSync(srcBinary, destBinary);
  fs.chmodSync(destBinary, 0o755);

  // Clean up.
  fs.rmSync(tmpDir, { recursive: true, force: true });

  console.log(`${BINARY} v${version} installed successfully.`);
}

main().catch((err) => {
  console.error(`Failed to install ${BINARY}: ${err.message}`);
  process.exit(1);
});
