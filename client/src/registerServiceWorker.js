import { register } from 'register-service-worker'

register('/service-worker.js', {
  registrationOptions: { scope: './' },
  ready (registration) {
    // console.log('Service worker is active.')
  },
  registered (registration) {
    // console.log('Service worker has been registered.')
    setInterval(() => {
      // console.log('RAN UPDATE FOR SW')
      registration.update();
    // }, 1000 * 60 * 60); // e.g. hourly checks
    }, 1000 * 60 * 2); // e.g. 2 mins
  },
  cached (registration) {
    // console.log('Content has been cached for offline use.')
  },
  updatefound (registration) {
    // console.log('New content is downloading.', registration)
    //todo: i am not sure why sometimes updatefound is the only function that runs and why other times it is updated()
    //i think this makes it so the new version bar won't show up if there isn't a service worker already loaded, meaning it should be their first page load after a cleared cache so the should already be updated.
    if(registration && registration.active && registration.active.state != null){
      document.dispatchEvent(
        new CustomEvent('swUpdated')
      )
    }
  },
  updated (registration) {
    // console.log('New content is available; please refresh.')
    //todo: i am not sure why sometimes updatefound is the only function that runs and why other times it is updated()
    //it seems to me that the updated() function gets called when there is no service worker defined and then one gets defined.
    // i.e. when you clear the cache then load the page. in this scenario we do not want the update bar to appear so i am turning it off for now.
    // document.dispatchEvent(
    //   new CustomEvent('swUpdated')
    // )
  },
  offline () {
    console.log('No internet connection found. App is running in offline mode.')
  },
  error (error) {
    console.error('Error during service worker registration:', error)
  }
})
