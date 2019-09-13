import axios from 'axios'

const {VUE_APP_BASE_API} = process.env

export const VUE_APP_API_PATH = '/api/v1'

// constants
export const IS_MOBILE = window.innerWidth <= 768
export const SCREEN_WIDTH = window.innerWidth
export const MAX_FILE_SIZE = 10485760
export const STANDARD_IMAGES_AND_DOCS = 'image/*, .doc, .docx, .pdf, .xls, .xlsx, .csv, .txt'
export const STANDARD_IMAGES_ONLY = 'image/*'
export const STANDARD_DOCS_ONLY = '.doc, .docx, .pdf, .xls, .xlsx, .csv, .txt'
//TODO: rules likely need to be adjusted
export const EMAIL_RULES = [
  v => !!v || "E-mail is required",
  v => /.+@.+/.test(v) || "E-mail must be valid"
]

export const BASIC_REQUIRED_RULE = [
  v => !!v || 'Field is required'
]

export const SNACKBARS = {
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

export function getSnackbar(type, text) {
  //if you need a custom snackbar build it in your component
  let snackbar = SNACKBARS[type]
  snackbar.text = text
  snackbar.enabled = true
  return snackbar
}

// functions
export async function getRequest (path, optionalParams, companyAbbreviation) {
  const apiPath = companyAbbreviation ?? 'flow'
  const {data, status} = await axios.get(`${VUE_APP_BASE_API}${VUE_APP_API_PATH}/${apiPath}${path}`, optionalParams)
  return {data, status}
}

export async function postRequest (path, body) {
  const {data, status} = await axios.post(`${VUE_APP_BASE_API}${path}`, body)
  return {data, status}
}

export async function putRequest (path, body) {
  const {data, status} = await axios.put(`${VUE_APP_BASE_API}${path}`, body)
  return {data, status}
}

export async function deleteRequest (path) {
  // not returning data as part of a delete
  const {status} = await axios.delete(`${VUE_APP_BASE_API}${path}`)
  return {status}
}

export function logError (e) {
  console.error('*** ERROR ***', e)
}
