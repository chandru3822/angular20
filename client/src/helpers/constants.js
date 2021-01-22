const {VUE_APP_ENV, VUE_APP_BASE_API, VUE_MAPBOX_ACCESS_TOKEN, VUE_MAPBOX_STYLE} = process.env

let constants = {}

//todo: randa temporary var to hide new process step status stuff from the ui
constants.SHOW_NEW_PSST = VUE_APP_ENV === 'local'  || VUE_APP_ENV === 'stage'

constants.VUE_APP_BASE_API = VUE_APP_BASE_API
constants.VUE_APP_API_PATH = '/api/v1'
constants.MAPBOX_ACCESS_TOKEN = VUE_MAPBOX_ACCESS_TOKEN || '***REMOVED***'
constants.MAPBOX_STYLE = VUE_MAPBOX_STYLE || 'mapbox://styles/mapbox/streets-v10'
constants.IS_MOBILE = window.innerWidth <= 768
constants.SCREEN_WIDTH = window.innerWidth
// constants.MAX_FILE_SIZE = 104857600 //100 mb
constants.MAX_FILE_SIZE = 209715200 //200 mb
constants.STANDARD_IMAGES_AND_DOCS = 'image/*, .doc, .docx, .pdf, .xls, .xlsx, .csv, .txt'
constants.STANDARD_IMAGES_ONLY = 'image/*'
constants.STANDARD_DOCS_ONLY = '.doc, .docx, .pdf, .xls, .xlsx, .csv, .txt'

//TODO: rules likely need to be adjusted
constants.EMAIL_RULES = [
  v => !!v || "E-mail is required",
  v => /.+@.+/.test(v) || "E-mail must be valid"
]
constants.BASIC_REQUIRED_RULE = [
  v => !!v || 'Field is required'
]
constants.USERNAME_RULES = [
  v => !!v || 'Username is required',
  v => !!v && v.length >= 3 || 'Must be at least 3 characters'
]
constants.COLOR_LIST = [
  '#e7211b', '#39b942', '#181e1e', '#eceb50',
  '#3ca5d6', '#9e4ed6', '#919393', '#e68f35',
  '#770909', '#1013c1', '#074f0a', '#42063e',
  '#402e11', '#98ffd5', '#ff7f9e', '#00fffc',
  '#3f3f3f', '#840046', '#3a0080', '#575f00'
]

constants.SNACKBARS = {
  ERROR: {
    y: 'top',
    x: null,
    mode: '',
    timeout: 5000,
    text: '',
    color: 'brRed',
    fontClass: 'secondary--text'
  },
  SUCCESS: {
    y: 'top',
    x: null,
    mode: '',
    timeout: 5000,
    // timeout: 5000000,
    text: '',
    color: 'brGreen',
    fontClass: 'secondary--text'
  },
  WARNING: {
    y: 'top',
    x: null,
    mode: '',
    timeout: 5000,
    text: '',
    color: 'brYellow',
    fontClass: 'secondary--text'
  }
}

constants.CSV_BLOB_TYPE = 'text/csv;charset=utf-8'

export default constants
