import axios from 'axios'

const {VUE_APP_BASE_API} = process.env

// constants
export const IS_MOBILE = window.innerWidth <= 768
export const SCREEN_WIDTH = window.innerWidth
export const MAX_FILE_SIZE = 10485760
export const SNACKBAR_ERROR = {
  enabled: false,
  y: 'top',
  x: null,
  mode: '',
  timeout: 5000,
  text: '',
  color: 'brRed',
  fontClass: 'secondary--text'
}
export const SNACKBAR_SUCCESS = {
  enabled: false,
  y: 'top',
  x: null,
  mode: '',
  timeout: 5000,
  text: '',
  color: 'brGreen',
  fontClass: 'secondary--text'
}
export const SNACKBAR_WARNING = {
  enabled: false,
  y: 'top',
  x: null,
  mode: '',
  timeout: 5000,
  text: '',
  color: 'brYellow',
  fontClass: 'secondary--text'
}

// functions
export async function getRequest (path, optionalParams) {
  const {data, status} = await axios.get(`${VUE_APP_BASE_API}${path}`, optionalParams)
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


