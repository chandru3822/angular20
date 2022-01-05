import { getRequest, getRequestWithParams } from '@/helpers/helpers'

export async function getStates() {
  return await getRequest(`/state`)
}

export async function getAvailableStates() {
  return await getRequest(`/state/available`)
}

export async function getCompanyStates(companyId) {
  let params = { companyId }
  return await getRequestWithParams(`/state/company`, { params })
}

export async function getActiveStates() {
  return await getRequest(`/state/active`)
}

export async function getActiveStatesByHierarchy() {
  return await getRequest(`/state/activeByHierarchy`, null, [])
}
