# Webpack Configuration Generator for ES Modules
# Generates webpack.config.esm.js for ESM module build

let config = import "../../../src/config.ncl" in

# Generate JavaScript module export format
let webpack_config = {
  mode = "production",
  entry = "./src/index.ts",
  target = "node",

  output = {
    path = "path.resolve(__dirname, 'lib')",
    filename = "index.js",
    libraryTarget = "module",
    module = true,
    clean = false,
  },

  experiments = {
    outputModule = true,
  },

  resolve = {
    extensions = [".ts", ".js"],
  },

  module = {
    rules = [
      {
        test = "/\\.ts$/",
        use = "ts-loader",
        exclude = "/node_modules/",
      },
    ],
  },

  externals = {
    # Don't bundle Node.js built-in modules
    crypto = "crypto",
    https = "https",
    http = "http",
    url = "url",
    # Don't bundle dependencies (they should be in node_modules)
    elliptic = "elliptic",
    "node-fetch" = "node-fetch",
    sha256 = "sha256",
  },

  optimization = {
    minimize = true,
  },

  devtool = "source-map",
} in

# Format as JavaScript module.exports
m%"const path = require('path');

module.exports = %{std.serialize 'Json webpack_config};"%
