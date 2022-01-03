import { getRequest } from '@/helpers/helpers'

export async function getOrgTypes() {
  return await getRequest(`/orgType`)
}

export async function getSchedulingOrgTypes() {
  return await getRequest(`/orgType/schedulable`)
}

export async function getOrgsByType(typeId) {
  return await getRequest(`/org/getOrgsByType/${typeId}`)
}

export async function getOrgFilters() {
  return await getRequest(`/org/filters`, null, [])
}

export async function getOrgLevels() {
  return await getRequest(`/orgType/levels`)
}
