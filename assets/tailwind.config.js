// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration
module.exports = {
  content: [
    './js/**/*.js',
    '../lib/*_web.ex',
    '../lib/*_web/**/*.*ex'
  ],
  theme: {
    extend: {
      screens: {
        'xs': '520px',
      },
      colors: {
        'burgandy': '#6f1d1b',
        'orange': '#bc827a',
        'burgandy-light': "#F1E8E8"
      },
    },
    fontFamily: {
      sans: ['Mukta', 'sans-serif'],
      title: ['Yeseva One', 'cursive']
    },

  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/line-clamp')
  ]
}
