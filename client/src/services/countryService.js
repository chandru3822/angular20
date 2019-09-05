import axios from 'axios'

const {VUE_APP_BASE_API} = process.env

export async function getCountries() {
  try {
    const {data, status} = await axios.get(`${VUE_APP_BASE_API}/api/v1/flow/country`)
    return {data, status}
  } catch (e) {
    throw e
  }
}



