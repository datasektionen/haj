// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).

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
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"
import Alpine from "alpinejs";
import intersect from '@alpinejs/intersect'
import collapse from '@alpinejs/collapse'

window.Alpine = Alpine
Alpine.plugin(intersect)
Alpine.plugin(collapse)
Alpine.start()

let Hooks = {};

Hooks.Flash = {
    mounted() {
        let hide = () => liveSocket.execJS(this.el, this.el.getAttribute("phx-click"))
        this.timer = setTimeout(() => hide(), 8000)
        this.el.addEventListener("phx:hide-start", () => clearTimeout(this.timer))
        this.el.addEventListener("mouseover", () => {
            clearTimeout(this.timer)
            this.timer = setTimeout(() => hide(), 8000)
        })
    },
    destroyed() { clearTimeout(this.timer) }
}

let Uploaders = {}

Uploaders.S3 = function (entries, onViewError) {
    entries.forEach(entry => {

        let formData = new FormData()
        let { url, fields } = entry.meta

        Object.entries(fields).forEach(([key, val]) => formData.append(key, val))
        formData.append("file", entry.file)

        let xhr = new XMLHttpRequest()
        onViewError(() => xhr.abort())
        xhr.onload = () => xhr.status === 204 ? entry.progress(100) : entry.error()
        xhr.onerror = () => entry.error()

        xhr.upload.addEventListener("progress", (event) => {
            if (event.lengthComputable) {
                let percent = Math.round((event.loaded / event.total) * 100)
                if (percent < 100) { entry.progress(percent) }
            }
        })

        xhr.open("POST", url, true)
        xhr.send(formData)
    })
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
    params: { _csrf_token: csrfToken },
    uploaders: Uploaders,
    hooks: Hooks,
    dom: {
        onBeforeElUpdated(from, to) {
            if (from._x_dataStack) {
                window.Alpine.clone(from, to)
            }
        }
    },
})

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

