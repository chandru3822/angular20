import {getRequest} from '@/helpers/helpers'

export async function getEventTypes() {
  try {
    const {data, status} = await getRequest(`/event`)
    return {data, status}
  } catch (e) {
    throw e
  }
}




