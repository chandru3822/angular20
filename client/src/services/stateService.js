import {getRequest} from '@/helpers/helpers'

export async function getStates() {
  try {
    const {data, status} = await getRequest(`/state`)
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



