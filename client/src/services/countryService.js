import { getRequestWithParams} from '@/helpers/helpers'

export async function getCountries(companyId) {
  try {
    let params = {
      companyId
    }
    const {data, status} = await getRequestWithParams(`/country/company`, {params})
    return {data, status}
  } catch (e) {
    throw e
  }
}



