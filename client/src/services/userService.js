import {getRequest} from '@/helpers/helpers'

export async function getUserStatusTypes() {
  try {
    const {data} = await getRequest(`/user/statuses`)
    return {data, status}
  } catch (e) {
    throw e
  }
}




