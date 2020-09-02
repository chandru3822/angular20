import {getRequest, getRequestWithParams} from '@/helpers/helpers'

export async function getCompanyUserStatusTypes() {
  try {
    const {data} = await getRequest(`/user/statuses`)
    return {data, status}
  } catch (e) {
    throw e
  }
}




