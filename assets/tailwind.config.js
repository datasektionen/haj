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
      }
    },
    fontFamily: {
      sans: ['Mukta', 'sans-serif'],
      title: ['Yeseva One', 'cursive']
    },
  },
  plugins: [
    require('@tailwindcss/forms')
  ]
}
