// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"


let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken}
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// Persistent navbar toggle for LiveView navigations
function initNavbarToggle(root = document) {
  const toggleButton = root.getElementById ? root.getElementById('nav-toggle') : document.getElementById('nav-toggle');
  const menu = root.getElementById ? root.getElementById('nav-menu') : document.getElementById('nav-menu');
  if (!toggleButton || !menu) return;

  // Ensure menu is hidden on load for small screens
  if (window.matchMedia('(max-width: 767px)').matches) {
    menu.classList.add('hidden');
    toggleButton.setAttribute('aria-expanded', 'false');
  }

  // Remove previous handler to avoid duplicates
  toggleButton.__handler && toggleButton.removeEventListener('click', toggleButton.__handler);
  const handler = () => {
    const isHidden = menu.classList.contains('hidden');
    if (isHidden) {
      menu.classList.remove('hidden');
      toggleButton.setAttribute('aria-expanded', 'true');
    } else {
      menu.classList.add('hidden');
      toggleButton.setAttribute('aria-expanded', 'false');
    }
  };
  toggleButton.addEventListener('click', handler);
  toggleButton.__handler = handler;

  // Click outside to close (small screens)
  document.__navOutsideHandler && document.removeEventListener('click', document.__navOutsideHandler);
  const outsideHandler = (ev) => {
    const clickedInsideMenu = menu.contains(ev.target);
    const clickedToggle = toggleButton.contains(ev.target);
    if (!clickedInsideMenu && !clickedToggle && !menu.classList.contains('md:flex')) {
      if (!menu.classList.contains('hidden')) {
        menu.classList.add('hidden');
        toggleButton.setAttribute('aria-expanded', 'false');
      }
    }
  };
  document.addEventListener('click', outsideHandler);
  document.__navOutsideHandler = outsideHandler;
}

// Init once on load
window.addEventListener('DOMContentLoaded', () => initNavbarToggle(document));

// Re-init after LiveView patches and navigations
window.addEventListener('phx:page-loading-stop', () => initNavbarToggle(document));

