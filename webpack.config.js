const webpack = require('webpack');
const path = require('path');
const TerserPlugin = require('terser-webpack-plugin');
const WebpackObfuscator = require('webpack-obfuscator');

let config = {
	mode: 'development',
	entry: {
		main: './assets/scripts/coffee/main.coffee'
	},
	output: {
		path: path.resolve(__dirname, 'assets/scripts/js'),
		filename: '[name].js'
	},
	resolve: {
		extensions: ['.js', '.coffee']
	},
	module: {
		rules: [
			{
				test: /\.coffee$/,
				exclude: /node_modules/,
				loader: 'coffee-loader',
				options: {
					bare: true,
					transpile: {
						presets: ['@babel/env']
					}
				}
			},
			{
				test: /\.m?js$/,
				exclude: /node_modules/,
				use: {
					loader: 'babel-loader',
					options: {
						presets: ['@babel/env']
					}
				}
			}
		]
	},
	plugins: []
}

if(process.env.NODE_MODE === 'production') {
	config.plugins.push(new WebpackObfuscator({
		numbersToExpressions: false,
		transformObjectKeys: true,
		simplify: true,
		stringArray: true,
		stringArrayShuffle: false,
		stringArrayRotate: false,
		stringArrayThreshold: 1,
		splitStrings: true,
		splitStringsChunkLength: 10,
		target: 'browser-no-eval',
		identifierNamesGenerator: 'mangled-shuffled'
	}, []));
	config.mode = 'production';
	config.optimization = {
		minimize: true,
		minimizer: [new TerserPlugin()]
	}
}

module.exports = config;
