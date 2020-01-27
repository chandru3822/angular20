import {getRequest} from '@/helpers/helpers'

export async function getWorkQueueTypes() {
  try {
    const {data, status} = await getRequest(`/workQueueType`)
    return {data, status}
  } catch (e) {
    throw e
  }
}

export async function getWorkQueueCategories() {
  try {
    const {data, status} = await getRequest(`/workQueueCategory`)
    return {data, status}
  } catch (e) {
    throw e
  }
}




