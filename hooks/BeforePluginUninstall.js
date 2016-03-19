#!/usr/bin/env node
'use strict';

let cwd = process.cwd();
let fs = require('fs');
let path = require('path');

console.log('Instagram Assets Picker BeforePluginUninstall.js, attempting to modify build.xcconfig');

let xcConfigBuildFilePath = path.join(cwd, 'platforms', 'ios', 'cordova', 'build.xcconfig');

try {
  let xcConfigBuildFileExists = fs.accessSync(xcConfigBuildFilePath);
} catch(e) {
  console.log('Could not locate build.xcconfig.');
  return;
}

console.log('xcConfigBuildFilePath: ', xcConfigBuildFilePath);

let lines = fs.readFileSync(xcConfigBuildFilePath, 'utf8').split('\n');

let headerSearchPathLineNumber;
lines.forEach((l, i) => {
  if (l.indexOf('HEADER_SEARCH_PATHS') > -1) {
    headerSearchPathLineNumber = i;
  }
});

if (lines[headerSearchPathLineNumber].indexOf('instagram-assets-picker') === -1) {
  console.log('build.xcconfig does not have header path for Instagram Assets Picker');
  return;
}

let line = lines[headerSearchPathLineNumber];
lines[headerSearchPathLineNumber] = line.replace(/\ "\$\(SRCROOT\)\/\$\(PRODUCT_NAME\)\/cordova-plugin-instagram-assets-picker\/GPUImageHeaders\"/i, '');

let newConfig = lines.join('\n');

fs.writeFile(xcConfigBuildFilePath, newConfig, function (err) {
  if (err) {
    console.log('error updating build.xcconfig, err: ', err);
    return;
  }
  console.log('successfully updated HEADER_SEARCH_PATHS in build.xcconfig');
});
