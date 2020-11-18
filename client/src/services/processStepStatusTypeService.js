import {getRequestWithParams} from '@/helpers/helpers'

export async function getStatusTypes(projectId, projectProcessStepId) {
  try {
    let params = {
      projectId,
      projectProcessStepId
    }
    const {data} = await getRequestWithParams(`/processStep/status`, { params })
    // const {data, status} = await getRequest(`/processStep/status`)
    return {data, status}
  } catch (e) {
    throw e
  }
}



