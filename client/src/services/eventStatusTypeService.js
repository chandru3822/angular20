import {getRequest, getRequestWithParams} from '@/helpers/helpers'

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
  return await getRequest(`/event/${eventId}/status`, null, [])
}

export function getStatusClass(rootTypeId) {
  return rootTypeId === 1 ? 'status-active' : rootTypeId === 2 ? 'status-complete' : 'status-cancelled'
}

export async function getCancelledCompanyStatusTypesAssignedToPpsEvent(ppsId, ppsEventId) {
  return await getRequestWithParams(
    `/projectProcessStep/${ppsId}/event/${ppsEventId}/cancelledAssigned`, null, null, []
  )
}
