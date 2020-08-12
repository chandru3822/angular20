import {getRequest, getRequestWithParams} from '@/helpers/helpers'

export async function getWorkQueueTypes(sortByName) {
  try {
    let params = {
      sortByName
    }
    const {data, status} = await getRequestWithParams(`/workQueueType`, {params})
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




