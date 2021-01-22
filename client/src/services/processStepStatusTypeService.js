import {getRequestWithParams} from '@/helpers/helpers'

export async function getCompanyStatusTypes(projectId, projectProcessStepId) {
  try {
    let params = {
      projectId,
      projectProcessStepId
    }
    const {data} = await getRequestWithParams(`/processStep/status/company`, { params })
    return {data, status}
  } catch (e) {
    throw e
  }
}

// these are the root status types
export async function getStatusTypes(projectId, projectProcessStepId) {
  try {
    let params = {
      projectId,
      projectProcessStepId
    }
    const {data} = await getRequestWithParams(`/processStep/status`, { params })
    return {data, status}
  } catch (e) {
    throw e
  }
}


