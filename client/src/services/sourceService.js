import axios from 'axios'

const {VUE_APP_BASE_API} = process.env

export async function getStates() {
  try {
    const {data, status} = await axios.get(`${VUE_APP_BASE_API}/api/v1/flow/source`)
    return {data, status}
  } catch (e) {
    throw e
  }
}



