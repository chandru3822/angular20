import axios from 'axios'

const {VUE_APP_BASE_API} = process.env

export async function getOrgTypes() {
  try {
    const {data, status} = await axios.get(`${VUE_APP_BASE_API}/api/v1/flow/orgType`)
    return {data, status}
  } catch (e) {
    throw e
  }
}

export async function getOrgsByType(typeId) {
  try {
    const {data, status} = await axios.get(`${VUE_APP_BASE_API}/api/v1/flow/org/getOrgsByType/${typeId}`)
    return {data, status}
  } catch (e) {
    throw e
  }
}




