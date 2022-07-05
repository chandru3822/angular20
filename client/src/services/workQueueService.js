import { getRequest, getRequestWithParams } from '@/helpers/helpers'

export async function getWorkQueueTypes(sortByName) {
  let params = { sortByName }
  return await getRequestWithParams(`/workQueueType`, { params })
}

export async function getWorkQueueCategories(isAdmin) {
  let url = isAdmin ? `/workQueueCategory/admin` : '/workQueueCategory'
  return await getRequest(url)
}
