import axios from 'axios'
import constants from './constants'

export function getSnackbar(type, text) {
  //if you need a custom snackbar build it in your component
  let snackbar = constants.SNACKBARS[type]
  snackbar.text = text
  snackbar.enabled = true
  return snackbar
}

// functions
export async function getRequest (path, companyAbbreviation) {
  const apiPath = companyAbbreviation ? 'company/' + companyAbbreviation : 'flow'
  try {
    const {data, status} = await axios.get(`${constants.VUE_APP_BASE_API}${constants.VUE_APP_API_PATH}/${apiPath}${path}`)
    return {data, status}
  } catch (e) {
    throw e
  }
}

export async function getRequestWithParams (path, params, companyAbbreviation) {
  const apiPath = companyAbbreviation ? 'company/' + companyAbbreviation : 'flow'
  try {
    const {data, status} = await axios.get(`${constants.VUE_APP_BASE_API}${constants.VUE_APP_API_PATH}/${apiPath}${path}`, params)
    return {data, status}
  } catch (e) {
    throw e
  }
}

export async function postRequest (path, body, companyAbbreviation) {
  const apiPath = companyAbbreviation ? 'company/' + companyAbbreviation : 'flow'
  try {
    const {data, status} = await axios.post(`${constants.VUE_APP_BASE_API}${constants.VUE_APP_API_PATH}/${apiPath}${path}`, body)
    return {data, status}
  } catch (e) {
    throw e
  }
}

export async function putRequest (path, body, companyAbbreviation) {
  const apiPath = companyAbbreviation ? 'company/' + companyAbbreviation : 'flow'
  try {
    const {data, status} = await axios.put(`${constants.VUE_APP_BASE_API}${constants.VUE_APP_API_PATH}/${apiPath}${path}`, body)
    return {data, status}
  } catch (e) {
    throw e
  }
}

export async function deleteRequest (path, companyAbbreviation) {
  const apiPath = companyAbbreviation ? 'company/' + companyAbbreviation : 'flow'
  // not returning data as part of a delete
  try {
    const {status} = await axios.delete(`${constants.VUE_APP_BASE_API}${constants.VUE_APP_API_PATH}/${apiPath}${path}`)
    return {status}
  } catch (e) {
    throw e
  }
}

export function logError (e) {
  console.error('*** ERROR ***', e)
}

export function jsonToCsv (data) {
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