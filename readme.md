**AWS S3 Image to Base64 String**

This prototype is to demonstrate how to convert an S3-hosted image into a base64 string, which can then be used in other processes.

The purpose here was to solve a CORS error when trying to programatically retrieve an S3-hosted image via a secure URL via JavaScript.  The approach used in this prototype avoids having to integrate the AWS SDK for JavaScript and the accompanying layers of authentication required due to JavaScript code being visible via inspect.

**Prototype Overview**

The app begins by retrieving a set of images from an S3 bucket folder and displays them on the page.

Clicking on an image triggers the following workflow:

1. The JS cacheImage() function parses the S3 folder name and image name from the URL, then submits these via an AJAX request to the Sinatra /cache\_image route.   
2. The Sinatra /cache\_image route calls the Ruby download\_s3\_file() method to download the selected image from the S3 bucket to the ./public/swap directory.  
3. Once the image has been downloaded, the Sinatra /cache\_image route returns a \<p\> element, which is then accessible in the *success* section of the JS cacheImage() function's AJAX request.  
4. The page is updated with the \<p\> element, at which point the JS retrieveImage() function verifies the element is present.  
5. The JS retrieveImage() function can (optionally) add the image to the page and then calls the JS getBase64FromImageUrl() function, which writes the image to a hidden canvas for creating the base64 string.  
6. Once the base64 string is output, the JS cleanupSwap() function can then be called, which makes an AJAX request to the Sinatra /purge\_image route.  
7. The Sinatra /purge\_image route calls the Ruby cleanup\_swap\_dir() method to delete the image from the ./public/swap directory.  
8. Once the image has been deleted, the Sinatra /purge\_image route returns a <p> element, which is then accessible in the *success* section of the JS cleanupSwap() function.  
9. The page is updated with the \<p\> element, at which point a conditional statement in the *success* section of the JS cleanupSwap() function is used to console log the status.

**Console Logging**

The following items are logged in the browser console:

1. S3 secure image URL (cacheImage imgUrl)

2. S3 folder and image name (cacheImage imageInfo)

3. Sinatra response to image cache AJAX request (result)

4. Base64 string for image (retrieveImage base64String)

5. (optional) Sinatra response to image purge AJAX request (result)

6. (optional) Image purge success message (Image successfully purged...)