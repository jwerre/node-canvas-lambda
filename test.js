const https = require('https');
const fs = require('fs');
const { createCanvas, registerFont } = require('canvas');
const fontFamily = 'Krub';

const downloadFont = (font) => {
	const file = fs.createWriteStream(`./${font}.ttf`);
	const fontUrl = `https://github.com/google/fonts/blob/main/ofl/${font.toLowerCase()}/${font}-Regular.ttf?raw=true`

	return new Promise( (resolve, reject) => {

		file
			.on('finish', resolve)
			.on('error', reject );

		https.get(fontUrl, (response) =>{
			response.pipe(file, {end:true})
		});

	});
}

exports.handler = async (event) => {

	// download font from github
	// await downloadFont(fontFamily)
	// registerFont(`./${fontFamily}.ttf`, { family: fontFamily });

	const canvas = createCanvas(400, 200)
	const ctx = canvas.getContext('2d')

	ctx.font = `30px ${fontFamily}`
	ctx.fillText(event.message || 'OK!', 50, 100)

	return {
		statusCode: 200,
		body: canvas.toDataURL(),
	};

}
