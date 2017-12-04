// Sends AJAX request to remove image from ./public/swap
function cleanupSwap(imageName) {

  $.ajax({
      url: "/purge_image",
      type: 'POST',
      data: { image_name: imageName },
      success: function(result) {
        
        console.log("result: ", result);
        $("#ajax_result").html(result);
        
        var status = $("#ajax_result").text();

        if (status === "AJAX request successfully received - image purged.") {

          console.log("Image successfully purged from ./public/swap");
        }
      }
  });
}


// Convert image URL (/public/swap/image.png) to base64 string
function getBase64FromImageUrl(url, cb) {
    
    var image = new Image();

    image.onload = function () {
        
      var canvas = document.createElement("canvas");
      canvas.width =this.width;
      canvas.height =this.height;
      imgWidth = Math.floor(canvas.width * 0.6);  // resize for adding image to PDF
      imgHeight = Math.floor(canvas.height * 0.6);

      canvas.getContext("2d").drawImage(this, 0, 0)

      cb(canvas.toDataURL("image/png"));
    };

    image.src = url;
}


// Retrieve cached image in ./public/swap
function retrieveImage(imageInfo) {

  var imageName = imageInfo[1];
  var status = $("#ajax_result").text();
  var image = "swap/" + imageName;

  if (status === "AJAX request successfully received - image cached.") {

    // use to view update on page, comment out cleanupSwap() call on line 64 or won't load image
    $("#ajax_result").append( "<img src='" + image + "'>" );

    // convert image to base64 string
    getBase64FromImageUrl(image, function(dataUri) {

      var base64String = dataUri;
      console.log("retrieveImage base64String: ", base64String);

      // cleanupSwap(imageName);  // comment this out if using 
    });
  }
}


// Cache S3 folder and file names to files array
function parseImageUrl(imgUrl) {

  var folder = imgUrl.split('/')[3];  // extract S3 folder name from URL
  var file = imgUrl.split('/').pop().split('?').shift();  // extract S3 image name from URL
  var parsedData = [folder, file];

  return parsedData;
}


// Make AJAX request to Sinatra route to prompt caching of images to ./public/swap
function cacheImage(imgUrl) {

  console.log("cacheImage imgUrl: ", imgUrl)

  var imageInfo = parseImageUrl(imgUrl);
  console.log("cacheImage imageInfo: ", imageInfo);

  $.ajax({
      url: "/cache_image",
      type: 'POST',
      data: { image_info: imageInfo },
      success: function(result) {
        
        console.log("result: ", result);
        $("#ajax_result").html(result);
        
        retrieveImage(imageInfo);
      }
  });
}