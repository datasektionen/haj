import easyMDE from "easymde";

const initEasyMDE = (element, id) =>
  new easyMDE({
    element: element,
    forceSync: true,
    status: false,
    spellChecker: false,
    minHeight: "120px",
    autosave: {
        enabled: true,
        uniqueId: id,
        delay: 1000,
    }
  });



RichText = {
  mounted() {
    // The textarea should be (the first) child of the form with the hook

    let textElem = this.el.querySelector("textarea");
    let textArea = initEasyMDE(textElem, this.el.id);

    this.beforeUnload = (e) => {
        if (this.el.dataset.changed === 'true') {
            e.preventDefault()
            e.returnValue = ''
          }
    }

    this.jsListener = ({detail}) => {
      document.querySelectorAll(detail.to).forEach(el => {
          liveSocket.execJS(el, el.getAttribute(detail.attr))
      })
    }

    area = this.el.querySelector("textarea")
    window.addEventListener('beforeunload', this.beforeUnload, true)
    window.addEventListener("phx:js-exec", this.jsListener)

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

  destroyed() {
    window.removeEventListener("beforeunload", this.beforeUnload, true);
    window.removeEventListener("phx:js-exec", this.jsListener);
  }
};

export default RichText;
