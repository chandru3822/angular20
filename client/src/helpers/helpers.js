import axios from 'axios'
import constants from './constants'
import { AppMutations } from '@/stores/AppStore'

export function getSnackbar(type, text) {
  //if you need a custom snackbar build it in your component
  let snackbar = constants.SNACKBARS[type]
  snackbar.text = text
  snackbar.enabled = true
  return snackbar
}

export function isLightColor(color) {
  const hex = color.replace('#', '');
  const c_r = parseInt(hex.substr(0, 2), 16);
  const c_g = parseInt(hex.substr(2, 2), 16);
  const c_b = parseInt(hex.substr(4, 2), 16);
  const brightness = ((c_r * 299) + (c_g * 587) + (c_b * 114)) / 1000;
  return brightness > 155;
}

export function getMinMaxRule (min, max) {
  return [
    v => (!v || (v && (v <= max))) || `Value must be less than ${max}`,
    v => (!v || (v && (v >= min))) || `Value must be greater than ${min}`,
  ]
}

export function getFileIcon(file) {
  switch (file.fileExtension) {
    case 'pdf':
      return 'mdi-file-pdf-outline'
    case 'doc':
    case 'docx':
      return 'mdi-file-word'
    case 'png':
    case 'jpg':
    case 'jpeg':
      return 'mdi-file-image'
    case 'csv':
    case 'xls':
    case 'xlsb':
    case 'xlsm':
    case 'xlsx':
      return 'mdi-file-table'
    case 'dxf':
    case 'dtf':
    case 'dwg':
      return 'mdi-file-cad'
    default: //basic file image
      return 'insert_drive_file'
  }
}

export function followLink(url, projectId) {
  //currently project_id is the only param this would work for
  let adjustedUrl = getUrlForLink(url, projectId)

  //the date stringify guarantees a new tab opens every time
  window.open(adjustedUrl, JSON.stringify(new Date()))
}

export function getUrlForLink(url, projectId) {
  //currently project_id is the only param this would work for
  if(url.includes("ALB_PROJECT_ID") && null !== projectId && undefined !== projectId) {
    //this part would not work globally but I am just trying to hack up a POC
    url = url.replace("ALB_PROJECT_ID", projectId)
  }
  if(url.includes("ALB_HOST")) {
    url = url.replace("ALB_HOST", (constants.VUE_APP_ENV === 'local' ? 'http://' : 'https://') + location.host)
  }
  return url
}

export function isNumberOrHyphen(val) {
  if (val.key !== '-' && isNaN(Number(val.key))) {
    return val.preventDefault();
  }
}

export function formatPhoneNumber(phoneNumberString) {
  let cleaned = ('' + phoneNumberString).replace(/\D/g, '')
  //dont allow a 1 to be the first char
  cleaned = cleaned.replace(/^1/, '')
  let match = cleaned.match(/^(\d{3})(\d{3})(\d{4})$/)
  if (match) {
    return '(' + match[1] + ') ' + match[2] + '-' + match[3]
  }
  return null
}

export function handleHidingGlobalLoader(instance, status) {
  //if a request is cancelled we should not turn off the spinner because the route changed and may have already turned the spinner back on
  //if the status is null it means that the request was cancelled (otherwise it will have a success or error status)
  if(status != null) {
    instance.$store.commit(AppMutations.SET_LOADING, false)
  }
}

// functions
// pass in [] as returnType if you need an empty result to return you an empty list instead of an object
export async function getRequest(path, companyAbbreviation, returnType = {}) {
  const apiPath = companyAbbreviation ? 'company/' + companyAbbreviation : 'flow'
  return await axios.get(`${constants.VUE_APP_BASE_API}${constants.VUE_APP_API_PATH}/${apiPath}${path}`) ?? {data: returnType, status: null}
}

export async function getRequestWithParams(path, params, companyAbbreviation, returnType = {}) {
  const apiPath = companyAbbreviation ? 'company/' + companyAbbreviation : 'flow'
  return await axios.get(`${constants.VUE_APP_BASE_API}${constants.VUE_APP_API_PATH}/${apiPath}${path}`, params) ?? {data: returnType, status: null}
}

export async function postRequest(path, body, companyAbbreviation, returnType = {}, extraParams = {}) {
  //"extraParams" can be used to cancel post requests and send in the token and/or the source
  const apiPath = companyAbbreviation ? 'company/' + companyAbbreviation : 'flow'
  return await axios.post(`${constants.VUE_APP_BASE_API}${constants.VUE_APP_API_PATH}/${apiPath}${path}`, body, extraParams) ?? {data: returnType, status: null}
}

export async function postRequestWithRequestParams(path, body, params, companyAbbreviation, returnType = {}) {
  const apiPath = companyAbbreviation ? 'company/' + companyAbbreviation : 'flow'
  return await axios.post(`${constants.VUE_APP_BASE_API}${constants.VUE_APP_API_PATH}/${apiPath}${path}`, body, {params}) ?? {data: returnType, status: null}
}

export async function putRequest(path, body, companyAbbreviation, returnType = {}) {
  const apiPath = companyAbbreviation ? 'company/' + companyAbbreviation : 'flow'
  return await axios.put(`${constants.VUE_APP_BASE_API}${constants.VUE_APP_API_PATH}/${apiPath}${path}`, body) ?? {data: returnType, status: null}
}

export async function putRequestWithRequestParams(path, body, params, companyAbbreviation, returnType = {}) {
  const apiPath = companyAbbreviation ? 'company/' + companyAbbreviation : 'flow'
  return await axios.put(`${constants.VUE_APP_BASE_API}${constants.VUE_APP_API_PATH}/${apiPath}${path}`, body, {params}) ?? {data: returnType, status: null}
}

export async function deleteRequest(path, companyAbbreviation) {
  const apiPath = companyAbbreviation ? 'company/' + companyAbbreviation : 'flow'
  // not returning data as part of a delete
  return await axios.delete(`${constants.VUE_APP_BASE_API}${constants.VUE_APP_API_PATH}/${apiPath}${path}`)
}

export async function deleteRequestWithPayload(path, companyAbbreviation) {
  const apiPath = companyAbbreviation ? 'company/' + companyAbbreviation : 'flow'
  return await axios.delete(`${constants.VUE_APP_BASE_API}${constants.VUE_APP_API_PATH}/${apiPath}${path}`)
}


export function logError(e) {
  console.error('*** ERROR ***', e)
}

export function jsonToCsv(data) {
  let csvData = []

  for (let key in data[0]) {
    csvData.push(`"${key}"`)
    csvData.push(',')
  }
  csvData.pop()
  csvData.push('\r\n')

  data.map(function (item) {
    for (let key in item) {
      // if value isn't nullish, cast Numbers to string. Else empty string
      let escapedCSV = (item[key]) ? item[key] + '' : '';
      if (escapedCSV.match(/[,"\n]/)) {
        escapedCSV = '"' + escapedCSV.replace(/\"/g, '""') + '"'
      }
      csvData.push(escapedCSV)
      csvData.push(',')
    }
    csvData.pop()
    csvData.push('\r\n')
  });

  return csvData.join('')
}
