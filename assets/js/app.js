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

    let enableAudio = () => {
      if (this.player.src) {
        if (this.player.readyState === 0) {
          document.removeEventListener("click", enableAudio);
        }
      }
    };
    document.addEventListener("click", enableAudio);
    this.el.addEventListener("js:listen_now", () => {});

    this.handleEvent("load", ({ url, timings }) => {
      formatted = timings.map((timing) => timing / 1000);
      this.player.src = url;
      this.timings = formatted;

      this.player.addEventListener("loadedmetadata", () => {
        this.duration = this.el.querySelector("#audio-duration");
        this.currentTime = this.el.querySelector("#audio-time");
        this.progressBar = this.el.querySelector("#audio-progress");
        this.duration.innerText = this.formatTime(this.player.duration);
        this.currentTime.innerText = this.formatTime(this.player.currentTime);
        this.pushEventTo(this.el, "loaded");
        this.stop();
      });
    });

    this.el.addEventListener("js:play_pause", () => {
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

    // Press l to log the current time in player, useful for creating timings
    this.debugTimings = [];
    this.el.addEventListener("keydown", (event) => {
      if (event.keyCode === 76) {
        // l
        event.preventDefault();
        this.debugTimings.push(parseInt(this.player.currentTime * 1000));
        console.log(this.debugTimings);
      }
    });
  },

  clearNextTimer() {
    clearTimeout(this.nextTimer);
    this.nextTimer = null;
  },

  play() {
    this.clearNextTimer();
    this.player.play().then(() => {
      this.progressTimer = setInterval(() => this.updateProgress(), 100);
    });
  },

  pause() {
    clearInterval(this.progressTimer);
    this.player.pause();
  },

  stop() {
    clearInterval(this.progressTimer);
    this.player.pause();
    this.updateProgress();
  },

  updateProgress() {
    if (isNaN(this.player.duration)) {
      return false;
    }
    if (!this.nextTimer && this.player.currentTime >= this.player.duration) {
      clearInterval(this.progressTimer);
      this.player.pause();
      this.pushEventTo(this.el, "js_paused");
      return;
    }

    currentLineIndex = this.timings.findLastIndex(
      (timing) => this.player.currentTime > timing - 0.2
    );

    if (currentLineIndex > -1) {
      if (currentLineIndex > 0) {
        this.lines[currentLineIndex - 1].classList.remove(
          "font-bold",
          "text-black"
        );
        this.lines[currentLineIndex - 1].classList.add("text-gray-600");
      }
      this.lines[currentLineIndex].classList.add("font-bold", "text-black");
      this.lines[currentLineIndex].classList.remove("text-gray-600");
      //this.lines[currentLineIndex].scrollIntoView({ behavior: "smooth", block: "center" });
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
        this.lines[i].classList.add("text-gray-600");
        this.lines[i].classList.remove("text-bold", "text-black");
      } else if (i === line) {
        this.lines[i].classList.add("text-black", "text-bold");
        this.lines[i].classList.remove("text-gray-600");
      } else {
        this.lines[i].classList.remove(
          "text-black",
          "text-bold",
          "text-gray-600"
        );
      }
    }
  },
};

Hooks.SearchElement = {
  mounted() {
    const searchBarContainer = this.el;
    document.addEventListener("keydown", (event) => {
      
      if (event.key !== "ArrowUp" && event.key !== "ArrowDown") {
        return;
      }

      const focusElemnt = document.querySelector(":focus");

      if (!focusElemnt) {
        return;
      }

      if (!searchBarContainer.contains(focusElemnt)) {
        return;
      }

      event.preventDefault();

      const tabElements = document.querySelectorAll(
        "#search-input, #search-results a"
      );
      const focusIndex = Array.from(tabElements).indexOf(focusElemnt);
      const tabElementsCount = tabElements.length - 1;

      if (event.key === "ArrowUp") {
        tabElements[focusIndex > 0 ? focusIndex - 1 : tabElementsCount].focus();
      }

      if (event.key === "ArrowDown") {
        tabElements[focusIndex < tabElementsCount ? focusIndex + 1 : 0].focus();
      }
    });
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
topbar.config({ barColors: { 0: "#6F1D1B" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (info) => topbar.show());
window.addEventListener("phx:page-loading-stop", (info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
