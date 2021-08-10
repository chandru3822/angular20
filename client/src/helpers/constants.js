const { VUE_APP_BASE_API, VUE_MAPBOX_ACCESS_TOKEN, VUE_MAPBOX_STYLE} = process.env

let constants = {}

constants.LOCAL_COLOR = 'pink'
constants.STAGE_COLOR = 'orange'
constants.FLUX_COLOR = 'purple'
constants.UAT_COLOR = 'blue' //this is a light blue color
constants.PROD_COLOR = 'primaryCustom' //this is the dark blue prod color
constants.VUE_APP_BASE_API = VUE_APP_BASE_API
constants.VUE_APP_API_PATH = '/api/v1'
constants.MAPBOX_ACCESS_TOKEN = VUE_MAPBOX_ACCESS_TOKEN || '***REMOVED***'
constants.MAPBOX_STYLE = VUE_MAPBOX_STYLE || 'mapbox://styles/mapbox/streets-v10'
constants.IS_MOBILE = window.innerWidth <= 768
constants.SCREEN_WIDTH = window.innerWidth
// constants.MAX_FILE_SIZE = 104857600 //100 mb
// constants.MAX_FILE_SIZE = 209715200 //200 mb
constants.MAX_FILE_SIZE = 1048576000 //1 gb
constants.STANDARD_IMAGES_AND_DOCS = 'image/*, .doc, .docx, .pdf, .xls, .xlsx, .csv, .txt'
constants.STANDARD_IMAGES_ONLY = 'image/*'
constants.STANDARD_DOCS_ONLY = '.doc, .docx, .pdf, .xls, .xlsx, .csv, .txt'

//TODO: rules likely need to be adjusted
constants.EMAIL_RULES = [
  v => !!v || "E-mail is required",
  v => /.+@.+/.test(v) || "E-mail must be valid"
]

constants.POSTAL_CODE_RULES = [
  v => (!v || (v && (v.length === 0 || v.length === 5 || v.length === 10))) || 'Must be 5 or 10 characters',
  v => /^\d{5}(?:[-\s]\d{4})?$/.test(v) || "Postal Code must be a valid format: ##### or #####-####"
]

constants.POSTAL_CODE_REQUIRED_RULES = [
  v => !!v || "Field is required",
  v => (!v || (v && (v.length === 0 || v.length === 5 || v.length === 10))) || 'Must be 5 or 10 characters',
  v => /^\d{5}(?:[-\s]\d{4})?$/.test(v) || "Postal Code must be a valid format: ##### or #####-####"
]

constants.CITY_RULES = [
  v => (!v || (v && (v.length <= 35))) || 'Must be 35 characters or less',
  v => /^[-.a-zA-Z0-9\s]+$/.test(v) || "City must only contain alphanumeric, hyphen, period, or whitespace characters"
]

constants.ADDRESS_RULES = [
  v => (!v || (v && (v.length <= 35))) || 'Must be 35 characters or less',
  v => /^[-#'.a-zA-Z0-9&\s]+$/.test(v) || "Address must only contain alphanumeric, whitespace, or [-#'.&] characters"
]

constants.PHONE_RULES = [
  v => (!v || (v && (v.length <= 20))) || 'Must be 20 characters or less',
  v => /^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$/.test(v) || "Please reformat the Phone field with a valid phone number"
]

constants.PHONE_REQUIRED_RULES = [
  v => !!v || "Field is required",
  v => (!v || (v && (v.length <= 20))) || 'Must be 20 characters or less',
  v => /^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$/.test(v) || "Please reformat the Phone field with a valid phone number"
]

constants.NAME_RULES = [
  v => (!v || (v && (v.length <= 35))) || 'Must be 35 characters or less',
  v => (!v || (/^[-.&//a-zA-Z0-9\s]+$/.test(v) )) || "Cannot contain special characters"
]

constants.NAME_REQUIRED_RULES = [
  v => !!v || "Field is required",
  v => (!v || (v && (v.length <= 35))) || 'Must be 35 characters or less',
  v => /^[-.&//a-zA-Z0-9\s]+$/.test(v) || "Cannot contain special characters"
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
