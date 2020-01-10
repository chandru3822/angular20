import {getRequest} from '@/helpers/helpers'

export async function getStatusTypes() {
  try {
    const {data, status} = await getRequest(`/processStep/status`)
    return {data, status}
  } catch (e) {
    throw e
  }
}



