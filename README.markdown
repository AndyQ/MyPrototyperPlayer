#PrototyperPlayback

PrototyperPlayback is the player only companian app for running interfaces created with Prototyper. This app is designed to demo the playback only component and has no editor functionality.

When running, you can navigate through your prototype design by tapping on the hotspots.

PrototyperPlayback is released under the MIT licence.

##Prototyper project format##
An exported Prototyper project is a zip file containing a bunch of images and a **project.json** file that describes the project, what images it contains, the hotspots defined on each image and where it links to.

The name of the zip file is also the name of the displayed project.

A sample project.json file is shown below:

### Sample project.json
```
{
  "projectName" : "demo",
  "startImage" : "Image1",
  "images" : [
    {
      "imageName" : "Image1",
      "links" : [
        {
          "rect" : "{{107, 89}, {114, 91}}",
          "linkedToId" : "Image2",
          "transition" : 3
        }
      ]
    },
    {
      "imageName" : "Image2",
      "links" : [
        {
          "rect" : "{{237, 275}, {343, 64}}",
          "linkedToId" : "Image1",
          "transition" : 4
        }
      ]
    }
  ]
}
```

### project.json format
- Note all image names are without extension as the app first tries to load a .jpg and then a .png if the jpg doesn't exist.

projectName - The name of the project (should be same name as zip file - used as part of validation)
startImage - The image name that is the start image when playback selected
images - A list of ImageDetail objects that describe an image and its defined links (hotspots)

An ImageDetails object contains:
imageName - The name of the image
links - A list of Imagelink objects that describe a linked image

An ImageLink object contains:
rect - A serialised rectangle (CGRect -> NSString) - comprising of {{x, y}, {width, height}}
linkedToId - The name of the image that will be linked to when tapped on the hotspot
transition - the transition to use when switching to the image

Transitions available are:
0 - No transition (just display image)
1 - Crossfade
2 - Slide in from left,
3 - Slide in From right,
4 - Slide out from left,
5 - Slide out from right,
6 - Push to left,
7 - Push to right

##License##

(MIT Licensed)

Copyright (c) 2014 Andy Qua

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
