var WebpackBar = require("webpackbar");
var HtmlWebpackPlugin = require("html-webpack-plugin");
var CopyPlugin = require("copy-webpack-plugin");
var webpack = require("webpack");
var LodashModuleReplacementPlugin = require("lodash-webpack-plugin");

module.exports = {
    entry: [
        `${__dirname}/scripts/index.js`,
        `${__dirname}/styles/style.scss`,
        "bootstrap",
    ],
    output: {
        path: `${__dirname}/dist`,
        filename: "[contenthash].js",
    },
    performance: {
        hints: false,
        maxEntrypointSize: 1.5e6,
        maxAssetSize: 1.5e6,
    },
    module: {
        rules: [{
                loader: "worker-loader",
                test: /\.worker\.js$/,
                options: {
                    filename: "[contenthash].js",
                },
            },
            {
                test: /\.(scss)$/,
                use: [{
                        loader: "style-loader",
                    },
                    {
                        loader: "css-loader",
                    },
                    {
                        loader: "postcss-loader",
                        options: {
                            plugins: function() {
                                return [require("autoprefixer")];
                            },
                        },
                    },
                    {
                        loader: "sass-loader",
                    },
                ],
            },
            {
                test: /\.css$/i,
                use: ["style-loader", "css-loader"],
            },
            {
                test: /\.(png|jpe?g|gif)$/i,
                use: [{
                    loader: "file-loader",
                }, ],
            },
        ],
    },
    plugins: [
        new webpack.ProvidePlugin({
            $: "jquery",
            jQuery: "jquery",
        }),
        new HtmlWebpackPlugin({
            filename: "game.html",
            template: `${__dirname}/html/game.html`,
            inject: "head",
            favicon: `${__dirname}/assets/images/favicon.png`,
        }),
        new LodashModuleReplacementPlugin(),
        new WebpackBar(),
        new CopyPlugin({
            patterns: [{
                from: `${__dirname}/assets`,
                to: "assets",
            }, ],
        }),
        new CopyPlugin({
            patterns: [{
                from: `${__dirname}/html/multiplayer.html`,
                to: "./multiplayer.html",
            }, ],
        }),
        new CopyPlugin({
            patterns: [{
                from: `${__dirname}/html/index.html`,
                to: "./index.html",
            }, ],
        }),
        new CopyPlugin({
            patterns: [{
                from: `${__dirname}/html/register.html`,
                to: "./register.html",
            }, ],
        }),
        new CopyPlugin({
            patterns: [{
                from: `${__dirname}/html/options.html`,
                to: "./options.html",
            }, ],
        }),
        new CopyPlugin({
            patterns: [{
                from: `${__dirname}/html/inventory.html`,
                to: "./inventory.html",
            }, ],
        }),
    ],
};
