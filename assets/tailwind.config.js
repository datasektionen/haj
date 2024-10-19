// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin");

module.exports = {
  content: ["./js/**/*.js", "../lib/*_web.ex", "../lib/*_web/**/*.*ex"],
  theme: {
    extend: {
      screens: {
        xs: "520px",
      },
      colors: {
        burgandy: "#6f1d1b",
        orange: "#bc827a",
        "burgandy-light": "#F1E8E8",
        burgandy: {
          50: "#F8E3E2",
          100: "#F0C2C1",
          200: "#E28A88",
          300: "#D34D4A",
          400: "#AC2C2A",
          500: "#6F1D1B",
          600: "#5A1716",
          700: "#421110",
          800: "#2D0C0B",
          900: "#150505",
        },
      },
      backgroundSize: {
        "size-125": "125% 125%",
      },
      backgroundPosition: {
        "pos-0": "0% 0%",
        "pos-100": "100% 100%",
      },
    },
    fontFamily: {
      sans: ["Mukta", "sans-serif"],
      title: ["Yeseva One", "cursive"],
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/typography"),
    plugin(({ addVariant }) =>
      addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-click-loading", [
        ".phx-click-loading&",
        ".phx-click-loading &",
      ])
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-submit-loading", [
        ".phx-submit-loading&",
        ".phx-submit-loading &",
      ])
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-change-loading", [
        ".phx-change-loading&",
        ".phx-change-loading &",
      ])
    ),
  ],
};
