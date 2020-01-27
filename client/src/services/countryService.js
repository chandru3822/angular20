import {getRequest} from '@/helpers/helpers'

export async function getCountries() {
  try {
    const {data, status} = await getRequest(`/country`)
    return {data, status}
  } catch (e) {
    throw e
  }
}



