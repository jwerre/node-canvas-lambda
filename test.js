const { createCanvas } = require('canvas');

exports.handler = async (event) => {
  const canvas = createCanvas(200, 200)
  const ctx = canvas.getContext('2d')
  console.log(event)
  ctx.font = '30px Impact'
  ctx.fillText('Awesome!', 50, 100)

  const response = {
    statusCode: 200,
    body: '<img src="' + canvas.toDataURL() + '" />',
  };
  return response;
}
