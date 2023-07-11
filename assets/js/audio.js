AudioPlayer = {
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

export default AudioPlayer;