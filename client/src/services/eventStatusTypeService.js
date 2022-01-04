import { getRequest } from '@/helpers/helpers'

export async function getCompanyEventStatusTypes() {
  return await getRequest(`/event/companyStatus`)
}

export async function getEventStatusTypes() {
  //these are at the root level
  return await getRequest(`/event/status`)
}

export async function getAvailableForEvent(eventId) {
  return await getRequest(`/event/status/company/availableForEvent/${eventId}`)
}

export async function getAssignedToEvent(eventId) {
  return await getRequest(`/event/status/company/availableForEvent/${eventId}`)
}
