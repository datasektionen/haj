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
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";
import Alpine from "alpinejs";
import intersect from "@alpinejs/intersect";
import collapse from "@alpinejs/collapse";
import easyMDE from "easymde";

let nowSeconds = () => Math.round(Date.now() / 1000);

window.Alpine = Alpine;
Alpine.plugin(intersect);
Alpine.plugin(collapse);
Alpine.start();

const initEasyMDE = (element) =>
  new easyMDE({
    element: element,
    forceSync: true,
    status: false,
    spellChecker: false,
    minHeight: "120px",
  });

let Hooks = {};

Hooks.Flash = {
  mounted() {
    let hide = () =>
      liveSocket.execJS(this.el, this.el.getAttribute("phx-click"));
    this.timer = setTimeout(() => hide(), 8000);
    this.el.addEventListener("phx:hide-start", () => clearTimeout(this.timer));
    this.el.addEventListener("mouseover", () => {
      clearTimeout(this.timer);
      this.timer = setTimeout(() => hide(), 8000);
    });
  },
  destroyed() {
    clearTimeout(this.timer);
  },
};

Hooks.RichText = {
  mounted() {
    // The textarea should be (the first) child of the form with the hook
    let textArea = initEasyMDE(this.el.querySelector("textarea"));

    this.handleEvent("set_richtext_data", (richtext_data) => {
      if (
        richtext_data.id === this.el.id &&
        richtext_data.richtext_data !== textArea.value()
      ) {
        textArea.value(richtext_data.richtext_data);
      }
    });

    textArea.codemirror.on("change", () => {
      this.pushEventTo(this.el, "richtext_updated", {
        richtext_data: textArea.value(),
      });
    });
  },
};

Hooks.AudioPlayer = {
  destroyed() {
    clearInterval(this.progressTimer);
    clearTimeout(this.nextTimer);
    this.player.pause();
  },

  mounted() {
    this.player = this.el.querySelector("audio");
    this.duration = this.el.querySelector("#audio-duration");
    this.currentTime = this.el.querySelector("#audio-time");
    this.progressBar = this.el.querySelector("#audio-progress");
    this.lines = this.el.querySelector("#song-lines").children;
    this.timings = [];

    this.handleEvent("load", ({ timings }) => {
      formatted = timings.map((timing) => timing / 1000);
      this.timings = formatted;

      this.duration = this.el.querySelector("#audio-duration");
      this.currentTime = this.el.querySelector("#audio-time");
      this.progressBar = this.el.querySelector("#audio-progress");
      this.duration.innerText = this.formatTime(this.player.duration);
      this.currentTime.innerText = this.formatTime(this.player.currentTime);
    });

    this.handleEvent("play_pause", () => {
      if (this.player.paused) {
        this.play();
      } else {
        this.pause();
      }
    });

    this.handleEvent("jump", ({ line }) => {
      time = this.timings[line];
      this.player.currentTime = this.timings[line];

      this.reformatLines(line);
      this.updateProgress();
    });

    this.handleEvent("pause", () => this.pause());
    this.handleEvent("stop", () => this.stop());
  },

  clearNextTimer() {
    clearTimeout(this.nextTimer);
    this.nextTimer = null;
  },

  play() {
    this.clearNextTimer();
    this.player.play().then(
      () => {
        this.progressTimer = setInterval(() => this.updateProgress(), 100);
      },
      (error) => {
        if (error.name === "NotAllowedError") {
          execJS("#enable-audio", "data-js-show");
        }
      }
    );
  },

  pause() {
    this.player.pause();
  },

  stop() {
    clearInterval(this.progressTimer);
    this.player.pause();
    this.player.currentTime = 0;
    this.updateProgress();
    this.duration.innerText = "";
    this.currentTime.innerText = "";
  },

  updateProgress() {
    if (isNaN(this.player.duration)) {
      return false;
    }
    if (!this.nextTimer && this.player.currentTime >= this.player.duration) {
      clearInterval(this.progressTimer);
      this.nextTimer = setTimeout(
        () => this.pushEvent("next_song_auto"),
        rand(0, 1500)
      );
      return;
    }
    

    currentLineIndex = this.timings.findLastIndex(
      (timing) => this.player.currentTime > timing - 0.2
    );

    console.log(this.timings);
    console.log(this.player.currentTime);

    if (currentLineIndex > -1) {
      if (currentLineIndex > 0) {
        this.lines[currentLineIndex - 1].classList.remove(
          "font-bold",
          "text-black"
        );
        this.lines[currentLineIndex - 1].classList.add("text-gray-700");
      }
      this.lines[currentLineIndex].classList.add("font-bold", "text-black");
      this.lines[currentLineIndex].classList.remove("text-gray-700");
    }

    this.progressBar.style.width = `${
      (this.player.currentTime / this.player.duration) * 100
    }%`;
    this.duration.innerText = this.formatTime(this.player.duration);
    this.currentTime.innerText = this.formatTime(this.player.currentTime);
  },

  formatTime(seconds) {
    return new Date(1000 * seconds).toISOString().substr(14, 5);
  },

  reformatLines(line) {
    for (let i = 0; i < this.lines.length; i++) {
      if (i < line) {
        this.lines[i].classList.add("text-black", "text-gray-700");
        this.lines[i].classList.remove("text-bold");
      } else if (i === line) {
        this.lines[i].classList.add("text-black", "text-bold");
        this.lines[i].classList.remove("text-gray-500");
      } else {
        this.lines[i].classList.remove(
          "text-black",
          "text-bold",
          "text-gray-700"
        );
      }
    }
  },
};

let Uploaders = {};

Uploaders.S3 = function (entries, onViewError) {
  entries.forEach((entry) => {
    let formData = new FormData();
    let { url, fields } = entry.meta;

    Object.entries(fields).forEach(([key, val]) => formData.append(key, val));
    formData.append("file", entry.file);

    let xhr = new XMLHttpRequest();
    onViewError(() => xhr.abort());
    xhr.onload = () =>
      xhr.status === 204 ? entry.progress(100) : entry.error();
    xhr.onerror = () => entry.error();

    xhr.upload.addEventListener("progress", (event) => {
      if (event.lengthComputable) {
        let percent = Math.round((event.loaded / event.total) * 100);
        if (percent < 100) {
          entry.progress(percent);
        }
      }
    });

    xhr.open("POST", url, true);
    xhr.send(formData);
  });
};

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  uploaders: Uploaders,
  hooks: Hooks,
  dom: {
    onBeforeElUpdated(from, to) {
      if (from._x_dataStack) {
        window.Alpine.clone(from, to);
      }
    },
  },
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (info) => topbar.show());
window.addEventListener("phx:page-loading-stop", (info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
