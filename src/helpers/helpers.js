import axios from 'axios'

const {VUE_APP_BASE_API} = process.env

export const IS_MOBILE = window.innerWidth <= 768
export const SCREEN_WIDTH = window.innerWidth

export async function getRequest (path) {
  const {data, status} = await axios.get(`${VUE_APP_BASE_API}${path}`)
  return {data, status}
}

export async function postRequest (path, body) {
  const {data, status} = await axios.post(`${VUE_APP_BASE_API}${path}`, body)
  return {data, status}
}
