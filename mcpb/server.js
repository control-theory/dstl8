const { spawnSync, spawn } = require("child_process");

const cmd = process.platform === "win32" ? "where" : "which";
const which = spawnSync(cmd, ["dstl8"], { stdio: "ignore" });

if (which.status !== 0) {
  process.stderr.write(
    [
      "dstl8 binary not found on PATH.",
      "",
      "Install it first:",
      "  macOS/Linux:  brew install control-theory/dstl8/dstl8",
      "  Other:        curl -fsSL https://install.dstl8.ai/script/dstl8-cli | sh",
      "  Or download:  https://github.com/control-theory/dstl8/releases",
      "",
      "After installing, restart Claude Desktop.",
    ].join("\n") + "\n"
  );
  process.exit(1);
}

const child = spawn("dstl8", ["mcp", ...process.argv.slice(2)], {
  stdio: "inherit",
});
child.on("exit", (code) => process.exit(code ?? 0));
