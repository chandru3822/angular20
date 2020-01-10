import {getRequest} from '@/helpers/helpers'

export async function getScheduleTypes() {
  try {
    const {data, status} = await getRequest(`/scheduleType`)
    return {data, status}
  } catch (e) {
    throw e
  }
}




