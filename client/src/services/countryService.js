import { getRequestWithParams } from '@/helpers/helpers'

export async function getCountries(companyId) {
  const params = { companyId }
  return await getRequestWithParams(`/country/company`, { params })
}
