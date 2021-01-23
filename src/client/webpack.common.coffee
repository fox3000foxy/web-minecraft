
WebpackBar=require "webpackbar"
HtmlWebpackPlugin = require "html-webpack-plugin"
CopyPlugin = require "copy-webpack-plugin"
webpack=require "webpack"
LodashModuleReplacementPlugin = require 'lodash-webpack-plugin'

module.exports=
	stats:"detailed"
	entry: "#{__dirname}/coffee/index.coffee"
	output:
		path: "#{__dirname}/dist"
		filename: '[contenthash].js'
	module:
		rules: [
			{
				test: /\.coffee$/
				loader: 'coffee-loader'
			}
		]
	optimization: 
		splitChunks: 
			cacheGroups: 
				babylon: 
					chunks: 'initial'
					test: /babylonjs/
					filename: '[contenthash].js'
	plugins:[
		new HtmlWebpackPlugin({
			filename: "index.html"
			template: "#{__dirname}/static/html/index.html"
			inject: "body"
		})
		new LodashModuleReplacementPlugin()
		new WebpackBar()
		new CopyPlugin({
			patterns: [
				{ from: "#{__dirname}/static/textures", to: "textures" }
			]
		})
	]