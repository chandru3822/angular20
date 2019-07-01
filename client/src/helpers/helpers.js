import axios from 'axios'

const {VUE_APP_BASE_API} = process.env

// constants
export const IS_MOBILE = window.innerWidth <= 768
export const SCREEN_WIDTH = window.innerWidth
export const MAX_FILE_SIZE = 10485760

// todo: should we allow customization via customer_id
export const userDataTypes = [
  {id: 1, dataType: 'Text', databaseTypeId: 5, hasMultiple: false},
  {id: 2, dataType: 'Date', databaseTypeId: 1, hasMultiple: false},
  {id: 3, dataType: 'Timestamp', databaseTypeId: 2, hasMultiple: false},
  {id: 4, dataType: 'Boolean', databaseTypeId: 3, hasMultiple: false},
  {id: 5, dataType: 'Integer', databaseTypeId: 7, hasMultiple: false},
  {id: 6, dataType: 'Decimal Number', databaseTypeId: 4, hasMultiple: false},
  {id: 7, dataType: 'Dropdown', databaseTypeId: 7, hasMultiple: true},
  {id: 8, dataType: 'Multi-Select', databaseTypeId: 9, hasMultiple: true},
]

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


