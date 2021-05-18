import {getRequest, getRequestWithParams} from '@/helpers/helpers'

export async function getCompanyEventStatusTypes(projectId) {
  try {
    const {data} = await getRequest(`/event/companyStatus`)
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

export async function getAssignedToEvent(eventId) {
  try {
    const {data} = await getRequest(`/event/status/company/availableForEvent/${eventId}`)
    return {data, status}
  } catch (e) {
    throw e
  }
}
