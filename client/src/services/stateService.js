import {getRequest, getRequestWithParams} from '@/helpers/helpers'

export async function getStates() {
  try {
    const {data, status} = await getRequest(`/state`)
    return {data, status}
  } catch (e) {
    throw e
  }
}

export async function getAvailableStates() {
  try {
    const {data, status} = await getRequest(`/state/available`)
    return {data, status}
  } catch (e) {
    throw e
  }
}

export async function getCompanyStates(companyId) {
  try {
    let params = {
      companyId
    }
    const {data, status} = await getRequestWithParams(`/state/company`, {params})
    return {data, status}
  } catch (e) {
    throw e
  }
}

export async function getActiveStates() {
  try {
    const {data, status} = await getRequest(`/state/active`)
    return {data, status}
  } catch (e) {
    throw e
  }
}

export async function getActiveStatesByHierarchy() {
  try {
    const {data, status} = await getRequest(`/state/activeByHierarchy`, null, [])
    return {data, status}
  } catch (e) {
    throw e
  }
}



