import {getRequest, getRequestWithParams} from '@/helpers/helpers'

export async function getCompanyEventStatusTypes(projectId) {
  try {
    let params = {
      projectId
    }
    const {data} = await getRequestWithParams(`/event/companyStatus`, { params })
    return {data, status}
  } catch (e) {
    throw e
  }
}

export async function getEventStatusTypes() {
  //these are at the root level
  try {
    const {data} = await getRequest(`/event/status`)
    return {data, status}
  } catch (e) {
    throw e
  }
}

export async function getAvailableForEvent(eventId) {
  try {
    const {data} = await getRequest(`/event/status/company/availableForEvent/${eventId}`)
    return {data, status}
  } catch (e) {
    throw e
  }
}
