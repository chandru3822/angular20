import axios from 'axios'
import constants from './constants'
import moment from 'moment'
import Sortable from "sortablejs";
import cloneDeep from "lodash.clonedeep";
import { useAppStore } from '@/stores/AppStore.js'
import { useUserStore } from "@/stores/UserStore.js";

export function getSnackbar(type, text, displayMsgAsHtml) {
  //if you need a custom snackbar build it in your component
  let snackbar = constants.SNACKBARS[type]
  snackbar.text = text
  snackbar.displayAsHtml = displayMsgAsHtml
  snackbar.enabled = true
  return snackbar
}

export function getMonthDateRange(month, year) {
  let startDate = moment([year, month - 1]).format("YYYY-MM-DD")
  let endDate = moment(startDate).endOf('month').format("YYYY-MM-DD")
  return {startDate, endDate}
}

export function defineSortableTable (selector, items, orderField, saveFunction, arrayIndex, nonRef) {
  //note: `items` must be the ref, not the ref.value
  //note update: when i tried to pass in ref.value it would fail. but then on an object that wasn't a ref it worked fine. thus the `nonRef` property.
  //when the ref is an array of multiple sortable arrays in a for loop then send in the arrayIndex. see CompanyCustomFieldGroup.vue for example

  //todo look into if this is still an issue: vuetify table sorting is doing something weird where it won't sort right if i update the actual display order. hacked around it for now _rn
  let table = document.querySelector(selector)
  Sortable.create(table, {
    handle: '.handle',
    onEnd({ newIndex, oldIndex }) {
      let itemsToSort = arrayIndex !== null && arrayIndex !== undefined ? items.value[arrayIndex] : nonRef ? items : items.value
      const rowSelected = itemsToSort.splice(oldIndex, 1)[0]
      itemsToSort.splice(newIndex, 0, rowSelected)
      let fieldGroupsClone = cloneDeep(itemsToSort)
      //only save the rows that changed
      let rowsToSave = []
      fieldGroupsClone.forEach((g, idx) => {
        if(g[orderField] !== idx) {
          g[orderField] = idx
          rowsToSave.push(g)
        }
      })
      saveFunction(rowsToSave)
    }
  })
}

export function getYears(startingYear, sortDescending) {
  let yearEnd = parseInt(moment().format('YYYY'))
  let years = []
  for (let i = startingYear; i <= yearEnd; i++) {
    years.push(i)
  }
  //sort them descending
  return sortDescending ? years.reverse() : years
}

export function isLightColor(color) {
  const hex = color.replace('#', '')
  const c_r = parseInt(hex.substr(0, 2), 16)
  const c_g = parseInt(hex.substr(2, 2), 16)
  const c_b = parseInt(hex.substr(4, 2), 16)
  const brightness = ((c_r * 299) + (c_g * 587) + (c_b * 114)) / 1000
  return brightness > 155
}

export function getMinMaxRule(min, max) {
  return [
    v => (!v || (v && (v <= max))) || `Value must be less than ${max}`,
    v => (!v || (v && (v >= min))) || `Value must be greater than ${min}`
  ]
}

export function getAttachmentSourceId(projectId, ppsId, ppseId, userId, contactId, orgId) {
  //this is a very specific function that is only called by attachment functions to know which id to use as "source"
  //note: the order of these checks is important
  let sourceId, secondaryId;
  if(null != ppseId) {
    sourceId = ppseId
    secondaryId = ppsId
  } else {
    sourceId = null != ppsId ? ppsId :
      null != projectId ? projectId :
        null != userId ? userId :
          null != contactId ? contactId :
            null != orgId ? orgId : null
  }
  return { sourceId, secondaryId }
}

export function getFileIcon(file) {
  switch (file.fileExtension) {
    case 'pdf':
      return 'mdi-file'
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

export async function followLink(instance, url, params) {
  const appStore = useAppStore()
  let adjustedUrl = getUrlForLink(url, params)

  if(adjustedUrl.includes('CFGA_ID_')) {
    let urlParams = {
      ...params,
      currentLinkUrl: adjustedUrl
    }

    const {data, status} = await getRequestWithParams(`/links/buildUrl`, { params: urlParams })
    if(data === 'ERROR') {
      appStore.showSnack('ERROR', 'Error Generating Link. Please contact an administrator.')
    } else {
      adjustedUrl = data
      //the date stringify guarantees a new tab opens every time
      window.open(adjustedUrl, JSON.stringify(new Date()))
    }
  } else {
    //the date stringify guarantees a new tab opens every time
    window.open(adjustedUrl, JSON.stringify(new Date()))
  }

}

export function getHostUrl() {
  return (constants.VUE_APP_ENV === 'local' ? 'http://' : 'https://') + location.host
}

export function getUrlForLink(url, params) {
  if (url.includes('ALB_PROJECT_ID') && params?.projectId) {
    url = url.replace('ALB_PROJECT_ID', params?.projectId)
  }
  if (url.includes('ALB_PPS_ID') && params?.ppsId) {
    url = url.replace('ALB_PPS_ID', params?.ppsId)
  }
  if (url.includes('ALB_PPSE_ID') && params?.ppseId) {
    url = url.replace('ALB_PPSE_ID', params?.ppseId)
  }
  if (url.includes('ALB_CONTACT_ID') && params?.contactId) {
    url = url.replace('ALB_CONTACT_ID', params?.contactId)
  }
  if (url.includes('ALB_HOST')) {
    url = url.replace('ALB_HOST', getHostUrl())
  }
  return url
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

export function cleanPhoneNumberForCopying(phoneNumberString) {
    let cleaned = ('' + phoneNumberString).replace(/\D/g, '')
    //dont allow a 1 to be the first char
    cleaned = cleaned.replace(/^1/, '')
    let match = cleaned.match(/^(\d{3})(\d{3})(\d{4})$/)
    if(match) {
        return '' + match[1] + match[2] + match[3]
    }
    return null
}

export function handleHidingGlobalLoader(status) {
  //if a request is cancelled we should not turn off the spinner because the route changed and may have already turned the spinner back on
  //if the status is null it means that the request was cancelled (otherwise it will have a success or error status)
  if (status != null) {
    const appStore = useAppStore()
    appStore.loading = false
  }
}

// functions
// pass in [] as returnType if you need an empty result to return you an empty list instead of an object
export async function getRequest(path, companyAbbreviation = null, returnType = {}) {
  const apiPath = companyAbbreviation ? 'company/' + companyAbbreviation : 'flow'
  return await axios.get(`${constants.VUE_APP_BASE_API}${constants.VUE_APP_API_PATH}/${apiPath}${path}`) ?? {
    data: returnType,
    status: null
  }
}

export async function getRequestWithParams(path, params, companyAbbreviation = null, returnType = {}) {
  const apiPath = companyAbbreviation ? 'company/' + companyAbbreviation : 'flow'
  return await axios.get(`${constants.VUE_APP_BASE_API}${constants.VUE_APP_API_PATH}/${apiPath}${path}`, params) ?? {data: returnType, status: null}
}

export async function postRequest(path, body, companyAbbreviation = null, returnType = {}, extraParams = {}) {
  //"extraParams" can be used to cancel post requests and send in the token and/or the source
  const apiPath = companyAbbreviation ? 'company/' + companyAbbreviation : 'flow'
  return await axios.post(`${constants.VUE_APP_BASE_API}${constants.VUE_APP_API_PATH}/${apiPath}${path}`, body, extraParams) ?? {
    data: returnType,
    status: null
  }
}

export async function postRequestWithRequestParams(path, body, params, companyAbbreviation = null, returnType = {}) {
  const apiPath = companyAbbreviation ? 'company/' + companyAbbreviation : 'flow'
  return await axios.post(`${constants.VUE_APP_BASE_API}${constants.VUE_APP_API_PATH}/${apiPath}${path}`, body, { params }) ?? {
    data: returnType,
    status: null
  }
}

export async function putRequest(path, body, companyAbbreviation = null, returnType = {}) {
  const apiPath = companyAbbreviation ? 'company/' + companyAbbreviation : 'flow'
  return await axios.put(`${constants.VUE_APP_BASE_API}${constants.VUE_APP_API_PATH}/${apiPath}${path}`, body) ?? {
    data: returnType,
    status: null
  }
}

export async function putRequestWithRequestParams(path, body, params, companyAbbreviation = null, returnType = {}) {
  const apiPath = companyAbbreviation ? 'company/' + companyAbbreviation : 'flow'
  return await axios.put(`${constants.VUE_APP_BASE_API}${constants.VUE_APP_API_PATH}/${apiPath}${path}`, body, { params }) ?? {
    data: returnType,
    status: null
  }
}

export async function deleteRequest(path, companyAbbreviation = null) {
  const apiPath = companyAbbreviation ? 'company/' + companyAbbreviation : 'flow'
  // not returning data as part of a delete
  return await axios.delete(`${constants.VUE_APP_BASE_API}${constants.VUE_APP_API_PATH}/${apiPath}${path}`)
}

export async function deleteRequestWithPayload(path, companyAbbreviation = null) {
  const apiPath = companyAbbreviation ? 'company/' + companyAbbreviation : 'flow'
  return await axios.delete(`${constants.VUE_APP_BASE_API}${constants.VUE_APP_API_PATH}/${apiPath}${path}`)
}

export function apiRequest(companyAbbreviation, axiosConfig) {
  const companyPath = companyAbbreviation ? 'company/' + companyAbbreviation : 'flow'
  const apiPath = `${constants.VUE_APP_BASE_API}${constants.VUE_APP_API_PATH}/${companyPath}`
  return axios({
    baseURL: apiPath,
    ...axiosConfig
  })
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

  data.map(function(item) {
    for (let key in item) {
      // if value isn't nullish, cast Numbers to string. Else empty string
      let escapedCSV = (item[key]) ? item[key] + '' : ''
      if (escapedCSV.match(/[,"\n]/)) {
        escapedCSV = '"' + escapedCSV.replace(/\"/g, '""') + '"'
      }
      csvData.push(escapedCSV)
      csvData.push(',')
    }
    csvData.pop()
    csvData.push('\r\n')
  })

  return csvData.join('')
}

export function UUID() {
  return crypto.randomUUID()
}
function hex2(c) {
  c = Math.round(c);
  if (c < 0) c = 0;
  if (c > 255) c = 255;

  var s = c.toString(16);
  if (s.length < 2) s = "0" + s;

  return s;
}

function color(r, g, b) {
  return "#" + hex2(r) + hex2(g) + hex2(b);
}

export function shadeColorByPercent(col, light) {

  // TODO: Assert that col is good and that -1 < light < 1

  var r = parseInt(col.substr(1, 2), 16);
  var g = parseInt(col.substr(3, 2), 16);
  var b = parseInt(col.substr(5, 2), 16);

  if (light < 0) {
    r = (1 + light) * r;
    g = (1 + light) * g;
    b = (1 + light) * b;
  } else {
    r = (1 - light) * r + light * 255;
    g = (1 - light) * g + light * 255;
    b = (1 - light) * b + light * 255;
  }

  return color(r, g, b);
}

export function getEventColorClass (index) {
    const colorClassList = [
        'event-tile-red', 'event-tile-green', 'event-tile-yellow','event-tile-blue',
        'event-tile-orange', 'event-tile-purple', 'event-tile-cyan', 'event-tile-pink',
        'event-tile-lime',  'event-tile-magenta', 'event-tile-teal', 'event-tile-lavender',
        'event-tile-brown', 'event-tile-pale-yellow', 'event-tile-maroon', 'event-tile-mint',
        'event-tile-olive', 'event-tile-apricot', 'event-tile-navy', 'event-tile-dark-purple'
    ]
    return colorClassList[index%20]
}

export function getProjectPath() {
  const userStore = useUserStore()
  const projectPathSuffix = userStore.details.defaultProjectPage
  if (projectPathSuffix === null || projectPathSuffix === 'tab_status') {
    return {pathSuffix: 'status', tabName: 'status'}
  } else if (projectPathSuffix === 'tab_processSteps') {
    return {pathSuffix: 'processSteps', tabName: 'processSteps'}
  } else if (projectPathSuffix === 'tab_events') {
    return {pathSuffix: 'events', tabName: 'events'}
  } else if (projectPathSuffix === 'tab_work_queues') {
    return {pathSuffix: 'workQueues', tabName: 'workQueues'}
  } else{
    return {pathSuffix: 'details', tabName: projectPathSuffix}
  }
}
