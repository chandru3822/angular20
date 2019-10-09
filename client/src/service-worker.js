self.__precacheManifest = [].concat(self.__precacheManifest || []);
workbox.precaching.suppressWarnings();
workbox.precaching.precacheAndRoute(self.__precacheManifest, {});

// install new service worker when ok, then reload page.
self.addEventListener("message", msg=>{
  console.log('service worker message2: ', msg)
  if (msg.data.action==='skipWaiting'){
    self.skipWaiting()
  }
})
