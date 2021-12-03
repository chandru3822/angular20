import {getRequest} from '@/helpers/helpers'

export async function getOrgTypes() {
  try {
    const {data, status} = await getRequest(`/orgType`)
    return {data, status}
  } catch (e) {
    throw e
  }
}

export async function getSchedulingOrgTypes() {
  try {
    const {data, status} = await getRequest(`/orgType/schedulable`)
    return {data, status}
  } catch (e) {
    throw e
  }
}

export async function getOrgsByType(typeId) {
  try {
    const {data, status} = await getRequest(`/org/getOrgsByType/${typeId}`)
    return {data, status}
  } catch (e) {
    throw e
  }
}

export async function getOrgFilters() {
  try {
    const {data, status} = await getRequest(`/org/filters`, null, [])
    return {data, status}
  } catch (e) {
    throw e
  }
}

export async function getOrgLevels() {
  try {
    const {data, status} = await getRequest(`/orgType/levels`)
    return {data, status}
  } catch (e) {
    throw e
  }
}




