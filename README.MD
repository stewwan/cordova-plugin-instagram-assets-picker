# Cordova Instagram Assets Picker Plugin :camera: :video_camera: :scissors:

This is a cordova plugin for iOS that provides an image picker like Instagram, allowing you to crop photo and video with GPUImage.

![GIF](example.gif)

The app shown in the GIF is a demo app showing off the great [cordova-plugin-video-editor](https://github.com/jbavari/cordova-plugin-video-editor) and is using this plugin.  [Here is a YouTube video showing more of it](https://youtu.be/H4Tlj_9BC9g).  Check out how smooth the WKWebView is:exclamation:  I plan on putting the source code of this app on GitHub soon and will add a link to it here.

## Installation
```
cordova plugin add cordova-plugin-instagram-assets-picker
```
`InstagramAssetsPicker` will be available globally after deviceready.

## Usage

### Show the picker with videos, photos, or all media

``` javascript
InstagramAssetsPicker.getMedia(
  function(result) { // success cb
    console.log('getMedia success, result: ', JSON.stringify(result, null, 2));
    // result will be an object with at least a filePath property
    // you will only get the rect object when 'cropAfterSelect' is false
    // the rect object is required for the cropAsset function documented below

    /* example of result when the 'cropAfterSelect' option is set to false
    {
      filePath: "assets-library://asset/asset.m4v?id=4356310F-305C-4F87-9DD0-5277639CDDF6&ext=m4v",
      rect: {
        Width: 1,
        Height: 0.5625,
        Y: 0.249609375,
        X: 0
      }
    }
    */
  },
  function(err) { // error cb
    console.log('getMedia error, err: ', err);
  },
  { // options
    type: 'video', // accepts 'photo', 'video', or 'all' - defaults to all
    cropAfterSelect: false // see the note above for when this is false - defaults to false
  }
);
```

#### A note about the cropAfterSelect option with getMedia
The reason this option exists is to provide a better user experience.  It takes time to crop an asset with GPUImage so in most cases for a better UX you'll want to call `cropAsset` later with the result from the `getMedia` function.  This also allows showing your own UI loading indicator while the cropping is being performed.

#### A note about cropping using getMedia or cropAsset
The iOS simulator will not finish a crop using `getMedia` (with `cropAfterSelect` set to `true`) or `cropAsset`.  It works fine on a device.  I will be looking into why it doesn't work on the simulator.

### Crop a media asset from the device library
```javascript
InstagramAssetsPicker.cropAsset(
  function(result) { // success cb
    // result is the path to the media asset
    console.log('cropAsset success, result: ', result);
  },
  function(err) { // error cb
    console.log('cropAsset error, err: ', err);
  },
  { // options, both properties below are required
    filePath: "assets-library://asset/asset.m4v?id=4356310F-305C-4F87-9DD0-5277639CDDF6&ext=m4v",
    rect: {
      Width: 1,
      Height: 0.5625,
      Y: 0.249609375,
      X: 0
    }
  }
);
```

## Author

[Ross Martin](https://github.com/rossmartin)

## Reference

[InstagramAssetsPicker](https://github.com/Jexbat/InstagramAssetsPicker) (Modified by me to add features for this plugin and subtle improvements.)

## License

[The MIT License (MIT)](http://www.opensource.org/licenses/mit-license.html)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
