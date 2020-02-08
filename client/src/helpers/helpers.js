import axios from 'axios'

const {VUE_APP_BASE_API, VUE_MAPBOX_ACCESS_TOKEN, VUE_MAPBOX_STYLE} = process.env

export const VUE_BASE_API = VUE_APP_BASE_API

export const VUE_APP_API_PATH = '/api/v1'
export const MAPBOX_ACCESS_TOKEN = VUE_MAPBOX_ACCESS_TOKEN || '***REMOVED***'
export const MAPBOX_STYLE = VUE_MAPBOX_STYLE || 'mapbox://styles/mapbox/streets-v10'

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
export const COLOR_LIST = [
  '#e7211b', '#39b942', '#181e1e', '#eceb50',
  '#3ca5d6', '#9e4ed6', '#919393', '#e68f35',
  '#770909', '#1013c1', '#074f0a', '#42063e',
  '#402e11', '#98ffd5', '#ff7f9e', '#00fffc',
  '#3f3f3f', '#840046', '#3a0080', '#575f00'
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

export function isParent(parentId) {
  //todo: for now these ar the only functions where the frontend checks for a hardcoded id
  // to see if the company is a parent or not, maybe a better way?
  return parentId === 1 || parentId == null
}

export function isCompanyRoot(companyId) {
  //todo: for now these are the only functions where the frontend checks for a hardcoded id
  // to see if the company is the root parent company
  return companyId === 1
}

export function isSystemAdmin(highestCompanyId) {
  //todo: better way?
  return highestCompanyId === 1
}
// functions
export async function getRequest (path, companyAbbreviation) {
  const apiPath = companyAbbreviation ? 'company/' + companyAbbreviation : 'flow'
  try {
    const {data, status} = await axios.get(`${VUE_APP_BASE_API}${VUE_APP_API_PATH}/${apiPath}${path}`)
    return {data, status}
  } catch (e) {
    throw e
  }
}

export async function getRequestWithParams (path, params, companyAbbreviation) {
  const apiPath = companyAbbreviation ? 'company/' + companyAbbreviation : 'flow'
  try {
    const {data, status} = await axios.get(`${VUE_APP_BASE_API}${VUE_APP_API_PATH}/${apiPath}${path}`, params)
    return {data, status}
  } catch (e) {
    throw e
  }
}

export async function postRequest (path, body, companyAbbreviation) {
  const apiPath = companyAbbreviation ? 'company/' + companyAbbreviation : 'flow'
  try {
    const {data, status} = await axios.post(`${VUE_APP_BASE_API}${VUE_APP_API_PATH}/${apiPath}${path}`, body)
    return {data, status}
  } catch (e) {
    throw e
  }
}

export async function putRequest (path, body, companyAbbreviation) {
  const apiPath = companyAbbreviation ? 'company/' + companyAbbreviation : 'flow'
  try {
    const {data, status} = await axios.put(`${VUE_APP_BASE_API}${VUE_APP_API_PATH}/${apiPath}${path}`, body)
    return {data, status}
  } catch (e) {
    throw e
  }
}

export async function deleteRequest (path, companyAbbreviation) {
  const apiPath = companyAbbreviation ? 'company/' + companyAbbreviation : 'flow'
  // not returning data as part of a delete
  try {
    const {status} = await axios.delete(`${VUE_APP_BASE_API}${VUE_APP_API_PATH}/${apiPath}${path}`)
    return {status}
  } catch (e) {
    throw e
  }
}

export function logError (e) {
  console.error('*** ERROR ***', e)
}
