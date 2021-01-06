
buildPath="#{__dirname}/public"
require "./../server"
module.exports=(env)-> {
	mode: if (env and env.prod) then 'production' else 'development'
	entry: './index.js'
	output: {
			path: buildPath
			filename: 'bundle.js'
	}
	performance: {
			maxEntrypointSize: 1.5e6
			maxAssetSize: 1.5e6
	}
	stats: {
			modules: false
	}
	devtool: 'source-map'
	devServer: {
			contentBase: buildPath
			inline: true
			host: "0.0.0.0"
			stats: "minimal"
	},
	watchOptions: {
			aggregateTimeout: 500
			poll: 1000
			ignored: ["node_modules"]
	}
	optimization: {
			splitChunks: {
					cacheGroups: {
							babylon: {
									chunks: 'initial'
									test: /babylonjs/
									filename: 'babylon.js'
							},
					},
			},
	},
}
